# 📊 电商用户行为分析 · E-commerce User Behavior Analysis

基于真实电商埋点数据，做**转化漏斗**与 **RFM 用户分层**，并用 K-Means 交叉验证分层结果。

- 数据规模：2,756,101 条行为记录（去重后 2,664,218 条），1,407,580 位访客
- 时间跨度：2015-05 ~ 2015-09（约 4.5 个月）
- 事件类型：`view`（浏览）、`addtocart`（加购）、`transaction`（成交）
- 工具：Python · pandas · matplotlib · scikit-learn · Jupyter

---

## 📦 数据来源

- **数据集**：Retailrocket recommender system dataset（Kaggle，作者 Roman Zykov）
- **地址**：https://www.kaggle.com/datasets/retailrocket/ecommerce-dataset
- **许可**：CC BY-NC-SA 4.0 —— 使用需署名、仅限非商业用途、衍生作品相同方式共享
- **本次使用**：`events.csv`（行为日志）
- **未使用**：`item_properties.csv`（商品属性，数值已哈希）、`category_tree.csv`（类目树）

字段说明：

| 字段 | 含义 |
|---|---|
| timestamp | 事件时间，Unix 毫秒时间戳 |
| visitorid | 访客 ID（哈希） |
| event | 行为类型：view / addtocart / transaction |
| itemid | 商品 ID（哈希） |
| transactionid | 订单 ID，仅成交事件有值 |

---

## 🔍 一、转化漏斗

| 环节 | 事件数 | 环节转化率 |
|---|---|---|
| 浏览 view | 2,664,218 | — |
| 加购 addtocart | 68,966 | 2.59% |
| 成交 transaction | 22,457 | 32.56% |

**整体浏览→成交转化率 0.84%。**

> ⚠️ 注意口径：以上为**事件级**转化率（加购事件 ÷ 浏览事件），不是用户转化率。
> 用户级口径需按 `visitorid` 去重后重新计算，结论可能不同。

结论：**瓶颈在「浏览 → 加购」**（仅 2.59%），而不是「加购 → 成交」（32.56%，属于正常水平）。
优化重点应放在商品详情页的说服力和推荐精准度上，而不是支付环节。

---

## 👥 二、RFM 用户分层

以成交用户为对象：

- **R（Recency）**：最近一次成交距数据截止日的天数，四分位打分 4→1
- **F（Frequency）**：成交次数，四分位打分 1→4
- 按 R、F 得分划分四类用户：高价值 / 潜力 / 重要保持 / 流失

再用 **K-Means（k=4，标准化后聚类）** 对 R、F 二维特征聚类，与规则分层互相印证。

分层结果（约 1.2 万成交用户）：

| 类型 | 人数 |
|---|---|
| 高价值用户 | 2,981 |
| 流失用户 | 2,963 |
| 潜力用户 | 2,897 |
| 重要保持用户 | 2,878 |

结论：

- 绝大多数用户只浏览、不加购，流量利用率低
- 极少数用户贡献了大部分成交，呈现明显的长尾结构
- 高频用户的 Recency 显著更低，说明复购用户粘性强

> 局限：原始数据不含订单金额，**M（Monetary）维度缺失**，因此只用 R、F 两维；
> 若接入订单金额，可按经典 RFM 三维分层。

---

## 📁 目录结构

```
.
├── README.md
└── 电商用户行为分析.ipynb   # 漏斗分析 + RFM + K-Means
```

---

## 🚀 如何运行

1. 从 [Kaggle](https://www.kaggle.com/datasets/retailrocket/ecommerce-dataset) 下载数据集，解压得到 `events.csv`
2. 放到项目下的 `data/` 目录，把 notebook 中读取路径改为相对路径：
   ```python
   df = pd.read_csv('data/events.csv')
   ```
3. 依赖：`pandas`、`numpy`、`matplotlib`、`scikit-learn`
4. 从上到下依次运行即可

---

## 📈 后续计划

- [ ] 加入图表：漏斗图、DAU 趋势、RFM 四象限、分层占比
- [ ] 补用户级转化口径（按 visitorid 去重）
- [ ] K-Means 对频率做 log 变换 + 肘部法选 k，解决长尾导致的聚类失衡
- [ ] 结合 `category_tree.csv` 做品类维度分析
- [ ] 用逻辑回归 / 树模型预测「会不会加购」
