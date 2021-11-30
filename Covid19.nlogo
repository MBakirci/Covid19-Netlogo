turtles-own
  [ ;; basic properties from the Wilensky, U. (1998). NetLogo Virus model.
  sick?                ;; if true, the turtle is infectious
    remaining-immunity   ;; how many weeks of immunity the turtle has left
    sick-time            ;; how long, in weeks, the turtle has been infectious
  ;; basic properties for the covid-19 model.
    hospitalized?
    speed
    chance-recover
    infectiousness
    vacinated?
  ]


globals
  [ ;; basic global variables from the Wilensky, U. (1998). NetLogo Virus model.
  %infected            ;; what % of the population is infectious
    %immune              ;; what % of the population is immune
    carrying-capacity    ;; the number of turtles that can be in the world at one time
  ;; basic global variables for the covid-19 model.
    immunity-duration-min
    immunity-duration-max
    home-patches
    number-dead
    hospital-patches
    hospitalize ]          ;; create the patch for the hospital

breed [elderly elder]
breed [adults adult]
breed [youngadults youngadult]
breed [children child]



;; setup function from Wilensky, U. (1998). NetLogo Virus model.
;; The setup is divided into four procedures
to setup
  clear-all
  setup-constants
  create_hospital
  setup-turtles
  update-global-variables
  update-display
  reset-ticks
end

;; This sets up basic constants of the model.
to setup-constants
  set carrying-capacity 1000
  set immunity-duration-min 24 ;; 1 day
  set immunity-duration-max 24 * 365 / 4 ;; 3 months
end

to create_hospital
  ;; create the 'hospital'
  set home-patches patches with [pycor < 10 or (pxcor <  10 and pycor >= 10)]
  ask home-patches [ set pcolor yellow ]

  set hospital-patches patches with [pxcor > 10 and pycor > 10]
  ask hospital-patches [ set pcolor blue ]
end

;; We create a variable number of turtles of which 10 are infectious,
;; and distribute them randomly
to setup-turtles
  create-elderly number-people * 0.14
   [ setxy random-xcor random-ycor
    move-to-one-of home-patches
          set sick-time 0
    ifelse random-float 100 < %vacinated [set vacinated? true] [set vacinated? false]
      set remaining-immunity 0
      set size 1  ;; easier to see
      set speed 0.005
      set chance-recover chance-recover-elderly
      set infectiousness infectiousness-elderly
      set shape "leaf"

      get-healthy ]
  ask n-of sick-elderly  turtles
    [ get-sick ]

  create-adults number-people * 0.39
   [ setxy random-xcor random-ycor
    move-to-one-of home-patches
          set sick-time 0
    ifelse random-float 100 < %vacinated [set vacinated? true] [set vacinated? false]
      set remaining-immunity 0
      set size 1  ;; easier to see
      set speed 0.0015
      set chance-recover chance-recover-adults
      set infectiousness infectiousness-adults
      set shape "person business"
      get-healthy ]
  ask n-of sick-adults turtles
    [ get-sick ]

  create-youngadults number-people * 0.25
   [ setxy random-xcor random-ycor
    move-to-one-of home-patches
          set sick-time 0
    ifelse random-float 100 < %vacinated [set vacinated? true] [set vacinated? false]
      set remaining-immunity 0
      set size 1  ;; easier to see
      set speed 0.025
      set chance-recover chance-recover-youngadults
      set infectiousness infectiousness-youngadults
      set shape "person"
      get-healthy ]
  ask n-of sick-youngadults turtles
    [ get-sick ]

  create-children number-people * 0.22
      [ setxy random-xcor random-ycor
   move-to-one-of home-patches
          set sick-time 0
    ifelse random-float 100 < %vacinated [set vacinated? true] [set vacinated? false]
      set remaining-immunity 0
      set size 1  ;; easier to see
      set speed 0.035
      set chance-recover chance-recover-children
      set infectiousness infectiousness-children
      set shape "turtle"
      get-healthy ]
  ask n-of sick-children turtles
    [ get-sick ]


end

;; to update the globabl variables this function is used from Wilensky, U. (1998). NetLogo Virus model.
to update-global-variables
  if count turtles > 0
    [ set %infected (count turtles with [ sick? ] / count turtles) * 100
      set %immune (count turtles with [ immune? ] / count turtles) * 100 ]
end

;; modified update-display function from Wilensky, U. (1998). NetLogo Virus model.
to update-display
  ask turtles
      [ set color ifelse-value sick? [ red ] [ ifelse-value immune? [ grey ] [ green ] ] ]
end

to go
  ask turtles [
    get-older
    if pycor < 10 or (pxcor <  10 and pycor >= 10) or not sick? [move]
    if sick? [ recover-or-die]
    if sick? [ infect ]
  ]
  update-global-variables
  update-display
  tick
end

;; ;; modified get-older function from Wilensky, U. (1998). NetLogo Virus model.
;; the die parameter is removed
to get-older ;; turtle procedure
  if immune? [ set remaining-immunity remaining-immunity - 1 ]
  if sick? [ set sick-time sick-time + 1 ]
end

;; Turtles move about at random on a specific state.
to move

    ifelse sick?
    [ ifelse random-float 100 < %hospital / duration / 24 * (1 - (%vacinated / 100 * .75 ))  [ move-to-one-of hospital-patches] [if random-float 100 < (100 - lockdown-level * 20) [move-to-one-of home-patches]]]
    [if random-float 100 < (100 - lockdown-level * 20) [move-to-one-of home-patches]]


  let patch-under-me patch-here
      ifelse [pcolor] of patch-under-me = blue
  [set hospitalized? true]
    [set hospitalized? false]

end

;; Modified recover-or-die function from Wilensky, U. (1998). NetLogo Virus model.
to recover-or-die ;; turtle procedure
   if sick-time > duration * 24                      ;; If the turtle has survived past the virus' duration, then
    [ ifelse random-float 100 < chance-recover
      [ become-immune ]
      [ set number-dead number-dead + 1
        die ] ]
end

;; If a turtle is sick, it infects other turtles on the same patch.
;; Immune turtles don't get sick.
;; Modified infect function from Wilensky, U. (1998). NetLogo Virus model.
to infect ;; turtle procedure
  ask other turtles-here with [ not sick? and not immune? ]
    [ if random-float 100 < infectiousness * (((100 - masked) / 100)* 0.2)
      [ get-sick ] ]
end

to get-sick ;; turtle procedure
  set sick? true
  set remaining-immunity 0
end

to get-healthy ;; turtle procedure
  set sick? false
  set sick-time 0
end

to become-immune ;; turtle procedure
  set sick? false
  set sick-time 0
  set remaining-immunity immunity-duration-min + (random-float (immunity-duration-max - immunity-duration-min))
end

to move-to-one-of [locations]  ;; turtle procedure
  move-to one-of locations
end

;; check immume function from Wilensky, U. (1998). NetLogo Virus model.
to-report immune?
  report remaining-immunity > 0
end

;; startup Wilensky, U. (1998). NetLogo Virus model.
to startup
  setup-constants ;; so that carrying-capacity can be used as upper bound of number-people slider
end



; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
280
10
893
624
-1
-1
17.3
1
10
1
1
1
0
1
1
1
-17
17
-17
17
0
0
1
ticks
30.0

SLIDER
75
630
269
663
duration
duration
0.0
99.0
14.0
1.0
1
Days
HORIZONTAL

BUTTON
62
48
132
83
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
138
48
209
84
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
20
345
272
509
Populations
hours
people
0.0
240.0
0.0
300.0
true
true
"" ""
PENS
"sick" 1.0 0 -2674135 true "" "plot count turtles with [ sick? ]"
"immune" 1.0 0 -7500403 true "" "plot count turtles with [ immune? ]"
"healthy" 1.0 0 -10899396 true "" "plot count turtles with [ not sick? and not immune? ]"
"total" 1.0 0 -13345367 true "" "plot count turtles"
"deaths" 1.0 0 -955883 true "" "plot number-dead"

SLIDER
40
10
234
43
number-people
number-people
10
carrying-capacity
1000.0
1
1
NIL
HORIZONTAL

MONITOR
25
295
100
340
NIL
%infected
1
1
11

MONITOR
102
295
176
340
NIL
%immune
1
1
11

MONITOR
178
296
252
341
days
ticks / 24
1
1
11

SLIDER
280
630
472
663
%hospital
%hospital
0
100
4.0
1
1
NIL
HORIZONTAL

SLIDER
35
145
207
178
sick-elderly
sick-elderly
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
35
180
207
213
sick-adults
sick-adults
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
35
215
207
248
sick-youngadults
sick-youngadults
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
35
245
207
278
sick-children
sick-children
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
475
630
647
663
masked
masked
0
100
0.0
1
1
NIL
HORIZONTAL

MONITOR
20
515
77
560
deaths
number-dead
17
1
11

SLIDER
650
630
822
663
%vacinated
%vacinated
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
915
45
1120
78
chance-recover-elderly
chance-recover-elderly
95
100
99.6
0.1
1
NIL
HORIZONTAL

SLIDER
915
85
1120
118
chance-recover-adults
chance-recover-adults
95
100
99.8
0.1
1
NIL
HORIZONTAL

SLIDER
915
125
1120
158
chance-recover-youngadults
chance-recover-youngadults
98
100
99.88
0.01
1
NIL
HORIZONTAL

SLIDER
915
165
1122
198
chance-recover-children
chance-recover-children
98
100
99.917
0.001
1
NIL
HORIZONTAL

SLIDER
915
230
1107
263
infectiousness-elderly
infectiousness-elderly
0
100
14.0
1
1
NIL
HORIZONTAL

SLIDER
915
270
1110
303
infectiousness-adults
infectiousness-adults
0
100
14.0
1
1
NIL
HORIZONTAL

SLIDER
915
310
1110
343
infectiousness-youngadults
infectiousness-youngadults
0
100
14.0
1
1
NIL
HORIZONTAL

SLIDER
915
350
1112
383
infectiousness-children
infectiousness-children
0
100
14.0
1
1
NIL
HORIZONTAL

TEXTBOX
1165
45
1345
136
Legend\n\nleaf = Elderly\nperson business = Adults\nperson = Young Adults\nturtle = Children
12
0.0
1

SLIDER
825
630
997
663
lockdown-level
lockdown-level
0
4
1.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model simulates the transmission and perpetuation of the Covid-19 virus among the human population of the Netherlands.

This model is based on the Virus model in NetLogo and is extended with several Covid-19 related variables.

## HOW IT WORKS

The model is initialized with 1000 people, divided in several categories. initialy 10 are infected. People wander around the environment at random in one of three states: healthy (green), ill and infectious (red), immune (gray).
People may die as a result of infection. 

## HOW TO USE IT

Each "tick" represents an hour in the time scale of this model.

## RELATED MODELS

* Wilensky, U. (1998).  NetLogo Virus model. 

## CREDITS AND REFERENCES

This model can show an alternate visualization of the COVID-19 Virus model using different shapes to represent the people. It uses visualization techniques as recommended in the paper:

* Conor Stewart (2021) Statista. https://www.statista.com/statistics/1109459/coronavirus-death-casulaties-by-age-in-netherlands/

* CBS (2021). Population; gender, age and marital status https://opendata.cbs.nl/statline/#/CBS/nl/dataset/7461BEV/table?fromstatweb

* Lynne Peeples (Nature 586, 186-189 (2020)) Face masks: what the data say https://www.nature.com/articles/d41586-020-02801-8

* RIVM (in Dutch 2021) Vaccines very effective against hospital and ICU admissions, also for Delta variant https://www.rivm.nl/en/news/vaccines-very-effective-against-hospital-and-icu-admissions-also-for-delta-variant

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Virus model.  http://ccl.northwestern.edu/netlogo/models/Virus.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.


Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.



## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2192"/>
    <metric>count turtles</metric>
    <metric>count turtles with [hospitalized?]</metric>
    <metric>count turtles with [sick?]</metric>
    <enumeratedValueSet variable="infectiousness-youngadults">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%vacinated">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%hospital">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-recover-adults">
      <value value="99.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sick-adults">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectiousness-children">
      <value value="14"/>
    </enumeratedValueSet>
    <steppedValueSet variable="masked" first="1" step="1" last="100"/>
    <enumeratedValueSet variable="number-people">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sick-youngadults">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-recover-elderly">
      <value value="99.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectiousness-elderly">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-recover-children">
      <value value="99.917"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectiousness-adults">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown-level">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sick-elderly">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sick-children">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chance-recover-youngadults">
      <value value="99.88"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
