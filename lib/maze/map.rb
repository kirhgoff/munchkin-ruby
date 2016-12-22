require './lib/maze/maze'

#        The Junk Yard
#
# +----+----+----+----+----+----+
# |                             |      01 Entrance
# |                             |      02 Exit (up)
# +    +----+    +    +----+    +      03 Sanford Son's shop
# |    |    |         |    |    |
# |    |              |    |    |
# +    +----+    +    +-  -+    +----+
# | 02                            01 |
# |                                  |
# +    +-  -+    +    +-  -+    +----+
# |    | 03 |         |    |    |
# |    |    |         |    |    |
# +    +----+    +    +----+    +
# |                             |
# |                             |
# +----+----+----+----+----+----+


MAP=[
  [cell(:west, :north), cell(:north, :south), cell(:north), cell(:north), cell(:north, :south), cell(:north, :east)],
  [cell(:west, :east), room(:east), plain, cell(:east),   room(:south), cell(:west, :east)],
  [cell(:west), cell(:north), plain, plain, plain, plain, room(:west)],
  [cell(:west, :east), room(:north), cell(:west), cell(:east), room(:north), cell(:west, :east)],
  [cell(:west, :south), cell(:north, :south), cell(:south), cell(:south),  cell(:north, :south), cell(:east, :south)]
]