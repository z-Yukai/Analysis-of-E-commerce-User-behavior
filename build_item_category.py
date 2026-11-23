"""从 item_properties 生成 itemid -> categoryid 映射（供品类维度分析使用）。
用法：python build_item_category.py    # 需要先解压 item_properties_part1/2.csv 到 data/
"""
import pandas as pd

parts = []
for f in ["data/item_properties_part1.csv", "data/item_properties_part2.csv"]:
    for ch in pd.read_csv(f, chunksize=2_000_000, dtype={"itemid": "int64", "property": "str", "value": "str"}):
        cat = ch[ch.property == "categoryid"]
        if len(cat):
            parts.append(cat[["timestamp", "itemid", "value"]])

cat = pd.concat(parts).sort_values("timestamp").groupby("itemid").tail(1)
cat["categoryid"] = pd.to_numeric(cat.value, errors="coerce")
cat = cat.dropna(subset=["categoryid"])
cat.set_index("itemid")["categoryid"].astype("int64").to_csv(
    "data/item_category.csv", header=["categoryid"], index_label="itemid")
print(f"已生成数据/item_category.csv：{len(cat):,} 个商品 -> {cat.categoryid.nunique():,} 个类目")
