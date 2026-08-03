#!/usr/bin/env python3

import re

with open('init.lua.md', 'r', encoding='utf-8') as f:
    content = f.read()

blocks = re.findall(r'```code\n(.*?)\n```', content, re.DOTALL)

for i, block in enumerate(blocks, 1):
    # print(f"--- Blok {i} ---")
    print(block)
