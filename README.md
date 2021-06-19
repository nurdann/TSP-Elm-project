# Elm project

## How to run

```
$ npm install
$ elm install PaackEng/elm-google-maps
```

## Install

```
npm install -g elm
```

Initialize project

```
elm init
```

This is will create `elm.json` file and `src/` directory. The main file Elm looks for is `src/Main.elm`, it should have a header as follows

```elm
module Main exposing (..)
```

Then launch the application 

```
elm reactor
```

Launch interactive shell
```
elm repl
```

Initialize project

```
$ create-elm-app project
$ cd project && elm-app start
```

## Syntax

Records
```elm
>  john =
|   { first = "John"
|   , last = "Hobson"
|   , age = 81
|   }
| 
{ age = 81, first = "John", last = "Hobson" }

> john.last
"Hobson"

> .last john
"Hobson"

> List.map .last [john, john]
["Hobson", "Hobson"]

> {john | last "Adams" }
{ age = 81, first = "John", last = "Adams" }
```
source: https://guide.elm-lang.org/core_language.html

Elm consists of three main components: Model, View and Update. Model tracks the state of application, View produces HTML, and Update updates the state of Model.


In order to use pattern matching, we need to use `case` expression, for example

```elm
appendMap : a -> List (List a) -> List (List a)
appendMap item lists =
    case lists of
        [] -> [[item]]
        xs -> List.map (\sublist -> List.append sublist [item]) xs
```

In addition, each block of expression needs to indented with the same amount of space. Otherwise, there is an compile error.

The variable names cannot be reused within a subblock.

## Travelling salesman problem

### Brute force

We can generate all possible permutations of coordinate points and find the set of points that produce the smallest sum of their distances. But the permutations produces `n!` orderings so it is not feasible.

### Nearest neighbour 

The Nearest neighbour algorithms choose a random starting point and travels to the next nearest point. Then, it is treated as an origin point and again we look for the nearest point.


## Drawing the coordinate path

I have attempted using `elm-canvas` package but the resulting `<canvas>` did not draw anything.

We will use Google Maps API instead. For that, we need to get google API key. Follow [this to enable API](https://developers.google.com/maps/gmp-get-started#enable-api-sdk) and [enable billing](https://console.cloud.google.com/projectselector2/billing/enable)

Install elm package for Google Maps from [github](https://github.com/PaackEng/elm-google-maps/tree/2.1.0)
