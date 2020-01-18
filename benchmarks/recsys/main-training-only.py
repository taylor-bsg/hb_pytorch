#!/usr/bin/env python

"""
    recsys/main.py

    Node to program performers:
        - This is basically the same architecture as the ANN-Encoder workflow (#11 December)
"""

import os
import sys
import json
import argparse
import numpy as np
from tqdm import tqdm
from time import time

import torch
from torch import nn
from torch.nn import functional as F
from torch.utils.data import DataLoader, Dataset

torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False

from helpers import compute_topk

# --
# Data loaders

class RaggedAutoencoderDataset(Dataset):
    def __init__(self, X, n_toks):
        self.X      = [torch.LongTensor(xx) for xx in X]
        self.n_toks = n_toks

    def __getitem__(self, idx):
        x = self.X[idx]
        y = torch.zeros((self.n_toks,))
        y[x] += 1
        return x, y

    def __len__(self):
        return len(self.X)


def ragged_collate_fn(batch, pad_value=0):
    X, y = zip(*batch)

    max_len = max([len(xx) for xx in X])
    X = [F.pad(xx, pad=(max_len - len(xx), 0), value=pad_value).data for xx in X]

    X = torch.stack(X, dim=-1).t().contiguous()
    y = torch.stack(y, dim=0)
    return X, y


def make_dataloader(X, n_toks, batch_size, shuffle):
    return DataLoader(
        dataset=RaggedAutoencoderDataset(X=X, n_toks=n_toks),
        batch_size=batch_size,
        collate_fn=ragged_collate_fn,
        num_workers=4,
        pin_memory=True,
        shuffle=shuffle,
    )


# --
# Define model

class MLPEncoder(nn.Module):
    def __init__(self, n_toks, emb_dim, hidden_dim, dropout, bias_offset):
        super().__init__()

        self.emb = nn.Embedding(n_toks, emb_dim, padding_idx=0)
        torch.nn.init.normal_(self.emb.weight.data, 0, 0.01)
        self.emb.weight.data[0] = 0

        self.act_bn_drop_1 = nn.Sequential(
            nn.ReLU(),
            nn.BatchNorm1d(emb_dim),
            nn.Dropout(dropout),
        )

        self.bottleneck = nn.Linear(emb_dim, hidden_dim)
        self.bottleneck.bias.data.zero_()

        self.act_bn_drop_2 = nn.Sequential(
            nn.ReLU(),
            nn.BatchNorm1d(hidden_dim),
            nn.Dropout(dropout),
        )

        self.output = nn.Linear(hidden_dim, n_toks)
        self.output.bias.data.zero_()
        self.output.bias.data += bias_offset

    def forward(self, x):
        x = self.emb(x).sum(dim=1)
        x = self.act_bn_drop_1(x)
        x = self.bottleneck(x)
        x = self.act_bn_drop_2(x)
        x = self.output(x)
        return x


# --
# Command line

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--cache-path', type=str, default='data/cache')
    parser.add_argument('--save-path', type=str, default='data/trained')

    parser.add_argument('--batch-size', type=int, default=256)
    parser.add_argument('--emb-dim', type=int, default=800)
    parser.add_argument('--hidden-dim', type=int, default=400)

    parser.add_argument('--lr', type=float, default=0.01)
    parser.add_argument('--bias-offset', type=float, default=-10)
    parser.add_argument('--dropout', type=float, default=0.5)

    parser.add_argument('--seed', type=int, default=456)
    parser.add_argument('--cuda', action="store_true")
    parser.add_argument('--nthreads', type=int, default=0)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    if args.nthreads > 0:
        torch.set_num_threads(args.nthreads)
    _ = np.random.seed(args.seed)
    _ = torch.manual_seed(args.seed + 1)
    if args.cuda:
        _ = torch.cuda.manual_seed(args.seed + 2)


    # --
    # IO

    print('loading data', file=sys.stderr)
    X_train = np.load('%s_train.npy' % args.cache_path, allow_pickle=True)
    n_toks  = np.hstack(X_train).max() + 1

    # --
    # Model

    model = MLPEncoder(
        n_toks=n_toks,
        emb_dim=args.emb_dim,
        hidden_dim=args.hidden_dim,
        dropout=args.dropout,
        bias_offset=args.bias_offset
    )

    if args.cuda:
        model = model.to('cuda')

    # --
    # Train for one epoch

    print('train for one epoch', file=sys.stderr)

    shuf_dataloader = make_dataloader(X_train, n_toks, args.batch_size, shuffle=True)

    opt = torch.optim.Adam(model.parameters(), lr=args.lr)

    _ = model.train()

    t = time()

    for x, y in tqdm(shuf_dataloader, total=len(shuf_dataloader)):
        if args.cuda:
            x, y = x.cuda(), y.cuda()

        out  = model(x)
        loss = F.binary_cross_entropy_with_logits(out, y)

        opt.zero_grad()
        loss.backward()
        opt.step()

    elapsed = time() - t
    print('elapsed time =', elapsed, file=sys.stderr)

    # --
    # Save trained model

    print('save trained model', file=sys.stderr)
    torch.save(model, args.save_path)
