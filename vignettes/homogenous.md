# Simple Markov models (homogenous)
`r Sys.Date()`  



The most simple Markov models in health economic evaluation are models were transition probabilities between states do not change with time. Those are called *homogenous* or *time-homogenous* Markov models.

If you are not familiar with `heemod`, first consult the [introduction vignette](https://cran.r-project.org/web/packages/heemod/vignettes/introduction.html).

# Model description

In this example we will model the cost effectiveness of lamivudine/zidovudine combination therapy in HIV infection ([Chancellor, 1997](https://www.ncbi.nlm.nih.gov/pubmed/10169387)) further described in [Decision Modelling for Health Economic Evaluation](http://ukcatalogue.oup.com/product/9780198526629.do), page 32.

This model aims to compare costs and utilities of two treatment strategies, *monotherapy* and *combined therapy*.

Four states are described, from best to worst healtwise:

  * __A__: CD4 cells > 200 and < 500 cells/mm3;
  * __B__: CD4 < 200 cells/mm3, non-AIDS;
  * __C__: AIDS;
  * __D__: Death.

# Transition probabilities

Transition probabilities for the monotherapy study group are rather simple to implement:


```r
mat_mono <-
  define_matrix(
    .721, .202, .067, .010,
    .000, .581, .407, .012,
    .000, .000, .750, .250,
    .000, .000, .000, 1.00
  )
mat_mono
```

```
## An unevaluated matrix, 4 states.
## 
##   A     B     C     D    
## A 0.721 0.202 0.067 0.01 
## B 0     0.581 0.407 0.012
## C 0     0     0.75  0.25 
## D 0     0     0     1
```

The combined therapy group has its transition probabilities multiplied by `rr`, the relative risk of event for the population treated by combined therapy. Since $rr < 1$, the combined therapy group has less chance to transition to worst health states.

The probabilities to stay in the same state are equal to $1 - \sum p_{trans}$ where $p_{trans}$ are the probabilities to change to another state (because all transition probabilities from a given state must sum to 1).


```r
rr <- .509

mat_comb <-
  define_matrix(
    1-(.202*rr+.067*rr+.010*rr), .202*rr,   .067*rr, .010*rr,
    .000, 1-(.407*rr+.012*rr),   .407*rr,   .012*rr,
    .000, .000,                  1-.250*rr, .250*rr,
    .000, .000,                  .000,      1.00
  )
mat_comb
```

```
## An unevaluated matrix, 4 states.
## 
##   A                                         B                            
## A 1 - (0.202 * rr + 0.067 * rr + 0.01 * rr) 0.202 * rr                   
## B 0                                         1 - (0.407 * rr + 0.012 * rr)
## C 0                                         0                            
## D 0                                         0                            
##   C             D         
## A 0.067 * rr    0.01 * rr 
## B 0.407 * rr    0.012 * rr
## C 1 - 0.25 * rr 0.25 * rr 
## D 0             1
```

# State values

The costs of lamivudine and zidovudine are defined:


```r
cost_zido <- 2278
cost_lami <- 2086
```

In addition to drugs costs (called `cost_drugs` in the model), each state is associated to healthcare costs (called `cost_health`). Cost are discounted at a 6% rate with the `discount` function.

Efficacy in this study is measured in terms of life expectancy (called `life_year` in the model). Each state thus has a value of 1 life year per year, except death who has a value of 0. Life-years are not discounted in this example.

For example state A can be defined with `define_state`:


```r
A_mono <-
  define_state(
    cost_health = 2756,
    cost_drugs = cost_zido,
    cost_total = discount(cost_health + cost_drugs, .06),
    life_year = 1
  )
A_mono
```

```
## An unevaluated state with 4 values.
## 
## cost_health = 2756
## cost_drugs = cost_zido
## cost_total = discount(cost_health + cost_drugs, 0.06)
## life_year = 1
```

The other states for the monotherapy treatment group can be specified in the same way:


```r
B_mono <-
  define_state(
    cost_health = 3052,
    cost_drugs = cost_zido,
    cost_total = discount(cost_health + cost_drugs, .06),
    life_year = 1
  )
C_mono <-
  define_state(
    cost_health = 9007,
    cost_drugs = cost_zido,
    cost_total = discount(cost_health + cost_drugs, .06),
    life_year = 1
  )
D_mono <-
  define_state(
    cost_health = 0,
    cost_drugs = 0,
    cost_total = discount(cost_health + cost_drugs, .06),
    life_year = 0
  )
```

Similarly, for the the combined therapy treatment group, only `cost_drug` differs from the monotherapy treatment group:


```r
A_comb <-
  define_state(
    cost_health = 3052,
    cost_drugs = cost_zido + cost_lami,
    cost_total = discount(cost_health + cost_drugs, .06),
    life_year = 1
  )
B_comb <-
  define_state(
    cost_health = 3052 + cost_lami,
    cost_drugs = cost_zido,
    cost_total = discount(cost_health + cost_drugs, .06),
    life_year = 1
  )
C_comb <-
  define_state(
    cost_health = 9007 + cost_lami,
    cost_drugs = cost_zido,
    cost_total = discount(cost_health + cost_drugs, .06),
    life_year = 1
  )
D_comb <-
  define_state(
    cost_health = 0,
    cost_drugs = 0,
    cost_total = discount(cost_health + cost_drugs, .06),
    life_year = 0
  )
```

# State lists

All states from a treatment group must be combined in a state list with `define_state_list`:


```r
states_mono <-
  define_state_list(
    A_mono,
    B_mono,
    C_mono,
    D_mono
  )
```

```
## No named state -> generating names.
```

```r
states_mono
```

```
## A list of 4 unevaluated states with 4 values each.
## 
## State names:
## 
## A
## B
## C
## D
## 
## State values:
## 
## cost_health
## cost_drugs
## cost_total
## life_year
```

Similarly for combined therapy:


```r
states_comb <-
  define_state_list(
    A_comb,
    B_comb,
    C_comb,
    D_comb
  )
```

```
## No named state -> generating names.
```

# Model definition

Models can now be defined by combining a transition matrix and a state list with `define_model`:


```r
mod_mono <- define_model(
  transition_matrix = mat_mono,
  states = states_mono
)
mod_mono
```

```
## An unevaluated Markov model:
## 
##     0 parameter,
##     4 states,
##     4 state values.
```

For the combined therapy model:


```r
mod_comb <- define_model(
  transition_matrix = mat_comb,
  states = states_comb
)
```

# Running models

Both models can then be run for 20 years with `run_model`. Models are given simple names (`mono` and `comb`) in order to facilitate result interpretation:


```r
res_mod <- run_models(
  mono = mod_mono,
  comb = mod_comb,
  cycles = 20
)
```

By default models are run for one person starting in the first state (here state A).

Model values can then be compared with `summary`:


```r
summary(res_mod)
```

```
## 2 Markov models run for 20 cycles.
## 
## Initial states:
## 
##   N
## A 1
## B 0
## C 0
## D 0
##      cost_health cost_drugs cost_total life_year
## mono    45479.45   18176.56   44613.85  7.979173
## comb    89433.47   43596.75   81026.56 13.864239
```

The incremental cost-effectiveness ratio of the combiend therapy strategy is thus:

$$
\frac{81026.56 - 44613.85}{13.864239 - 7.979173} = 6187.307
$$

6187GBP per life-year gained.