

{r}

library(tidyverse)
library(ggdist)
theme_set(
  theme_minimal(
    base_size = 16,
    base_family = 'Source Sans Pro'
  ) +
    theme(panel.grid.minor = element_blank())
) 

As promised in the last newsletter, today, I will show you how to combine multiple visualizations of uncertainty to create one very powerful visualization which is known as the rain cloud plot.
So, a plot like this, it looks like this.

```{r}
colors <- thematic::okabe_ito(3)
names(colors) <- unique(palmerpenguins::penguins$species)
title_text <- glue::glue(
  'Penguin weights (in g) for the Species',  
  '<span style = "color:{colors["Adelie"]}">**Adelie**</span>,', 
  '<span style = "color:{colors["Chinstrap"]}">**Chinstrap**</span>', 
  'and',
  '<span style = "color:{colors["Gentoo"]}">**Gentoo**</span>', 
  .sep = ' '
)

palmerpenguins::penguins |> 
  filter(!is.na(sex)) |> 
  ggplot(aes(x = body_mass_g, fill = species, y = species)) +
  geom_boxplot(width = 0.1) +
  geom_dots(
    side = 'bottom', 
    height = 0.55,
    position = position_nudge(y = -0.075)
  ) +
  stat_slab(
    position = position_nudge(y = 0.075), 
    height = 0.75
  ) +
  scale_y_discrete(
    breaks = c('Adelie', 'Gentoo', 'Chinstrap')
  ) +
  scale_fill_manual(values = colors) +
  labs(
    x = element_blank(), 
    y = element_blank(), 
    title = title_text
  ) +
  theme(
    plot.title = ggtext::element_markdown(),
    legend.position = 'none'
  )
```



Basically this chart is a combination of density chart, box plot and dot histogram.
Alternatively, you could also show the exact data instead of a dot histogram.

```{r}
palmerpenguins::penguins |> 
  filter(!is.na(sex)) |> 
  ggplot(aes(x = body_mass_g, fill = species, y = species)) +
  geom_point(
    aes(color = species),
    shape = '|',
    size = 9,
    alpha = 0.3,
    position = position_nudge(y = -0.175)
  ) +
  geom_boxplot(
    width = 0.1,
    
  ) +
  stat_slab(
    position = position_nudge(y = 0.075), 
    height = 0.75
  ) +
  scale_y_discrete(
    breaks = c('Adelie', 'Gentoo', 'Chinstrap')
  ) +
  scale_fill_manual(values = colors) +
  scale_color_manual(values = colors) +
  labs(
    x = element_blank(), 
    y = element_blank(), 
    title = title_text
  ) +
  theme(
    plot.title = ggtext::element_markdown(),
    legend.position = 'none'
  )
```

Both of these combinations can give you a great deal of information of the distribution in the data.
So let's start to build this.

## Begin with box plots


First, we are going to create a box plot for each penguin species in our data set.
In this step, we can already make the width of the box plots narrower (since we know that we will need room and don't have any use for a huge box).

```{r}
palmerpenguins::penguins |> 
  filter(!is.na(sex)) |> 
  ggplot(aes(x = body_mass_g, fill = species, y = species)) +
  geom_boxplot(width = 0.1)
```

# Add the dots

Next, we can add the dot histogram with `geom_dots()` from `{ggdist}`.
Conveniently, this function has a argument called `side` that we can set to `"bottom"` to make our dots stack downwards.
Also, we can use `position_nudge()` to move all dots down a little bit so that they do not overlap with the box plots.

```{r}
library(ggdist)
palmerpenguins::penguins |> 
  filter(!is.na(sex)) |> 
  ggplot(aes(x = body_mass_g, fill = species, y = species)) +
  geom_boxplot(width = 0.1) +
  geom_dots(
    side = 'bottom', 
    position = position_nudge(y = -0.075)
  )
```


# Add the density plots

Now, let us finish our chart by adding the density plot.
Here, I am not going to use `geom_density()` or `stat_density()` but `stat_slab()` from `{ggdist}`.
You can think of the latter function as more or less the same but it behaves in a more convenient way for our purposes here.

```{r}
palmerpenguins::penguins |> 
  filter(!is.na(sex)) |> 
  ggplot(aes(x = body_mass_g, fill = species, y = species)) +
  geom_boxplot(width = 0.1) +
  geom_dots(
    side = 'bottom', 
    position = position_nudge(y = -0.075)
  ) +
  stat_slab(
    position = position_nudge(y = 0.075) # move up a little bit
  )
```

# Avoid overlapping

We're almost done.
But we need to do some fine-tuning.
Right now, the dots and densitys overlap.
That's not very nice.
We can fix that by setting the `height` arguments in `stat_slab()` and `geom_dots()`.


```{r}
palmerpenguins::penguins |> 
  filter(!is.na(sex)) |> 
  ggplot(aes(x = body_mass_g, fill = species, y = species)) +
  geom_boxplot(width = 0.1) +
  geom_dots(
    side = 'bottom', 
    position = position_nudge(y = -0.075),
    height = 0.55
  ) +
  stat_slab(
    position = position_nudge(y = 0.075), 
    height = 0.75
  )
```

That's it.
We've created our raincloud plot.
Of course, you can now style this however you like.
In the above images, I've just changed the colors and used colored labels in the title instead of using a y-axis and legend.

# Modifications

Finally, let me show you the nifty trick that I used to create the "bar code" instead of using a dot histogram.
Here's the code.

```{r}
palmerpenguins::penguins |> 
  filter(!is.na(sex)) |> 
  ggplot(aes(x = body_mass_g, fill = species, y = species)) +
  geom_boxplot(width = 0.1) +
  geom_point(
    aes(color = species),
    shape = "|",
    size = 10,
    alpha = 0.5,
    position = position_nudge(y = -0.175)
  ) +
  stat_slab(
    position = position_nudge(y = 0.075), 
    height = 0.75
  )
```

Basically, I have replaced `geom_dots()` by `geom_point()` and set it's shape to `¨|"`.
The rest is just setting the color, using transparency and shifting the points a bit downward.

# Further reading

So that's how you create raincloud plots.
If you want to read more about these, I recommend checking out [Cédric Scherer's excellent blog post](https://www.cedricscherer.com/2021/06/06/visualizing-distributions-with-raincloud-plots-and-how-to-create-them-with-ggplot2/).
