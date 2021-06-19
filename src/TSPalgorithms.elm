module TSPalgorithms exposing (..)
import Debug exposing (log, toString)

-- Pythagorean theorem
distance: (Float, Float) -> (Float, Float) -> Float
distance (x1, y1) (x2, y2) = ((x2 - x1)^2 + (y2 - y1)^2)^0.5

-- source: https://stackoverflow.com/a/43507769
rotations : List a -> List (List a)
rotations xs =
    let rotate ys len acc = 
            case len of
                0 -> acc
                _ -> case ys of
                         (z::zs) -> rotate (zs ++ [z]) (len - 1) ((zs ++ [z]) :: acc)
                         [] -> acc
    in rotate xs (List.length xs) []

permutations : List a -> List (List a)
permutations list = 
    case list of
        [] -> [[]]
        (x :: xs) -> List.concatMap (rotations << ((::) x)) (permutations xs)
                       
data : List (Float, Float)
data = [
 (1, 1),
 (2, 230),
 (3, 4),
 (5, 6),
 (3, 200)
 ]

pairListItems : List a -> List (a, a)
pairListItems list =
    let pairConsec list1 list2 pairs = 
            case (list1, list2) of
                ([], _) -> pairs
                (_, []) -> pairs
                (x::xs, y::ys) -> pairConsec xs ys (pairs ++ [(x, y)])
    in pairConsec list (List.drop 1 list) []
                              

pathDistances : List ((Float, Float), (Float, Float)) -> List Float
pathDistances pairCoordinates = List.map (\(p1, p2) -> distance p1 p2) pairCoordinates

-- Get optimal distance using all possible permutations
optimal : List (Float, Float) -> List (Float, Float)
optimal coordinates = 
    let paths = permutations coordinates
        distances = List.map pathDistances (List.map pairListItems paths)
        sumDistances = List.map List.sum distances
    in case (paths, sumDistances) of
           (d::ds, s::ss) -> getOptimal ds ss d s
           _ -> []

getOptimal : List (List (Float, Float)) -> List Float -> List (Float, Float) -> Float -> List (Float, Float)
getOptimal ps sums optPath pathCost = 
    case (ps, sums) of
        (d :: ds, s :: ss) -> 
            if pathCost > s then getOptimal ds ss d s
            else getOptimal ds ss optPath pathCost
        _ -> optPath

-- Nearest neighbour, pick first element as starting point
nearestNeighbour : List (Float, Float) -> List (Float, Float)
nearestNeighbour list = 
    let nearestNeighbourIterate list0 origin = 
            case findNearest origin list0 of
                Just nearest -> nearest :: nearestNeighbourIterate (removeMatching list0 nearest) nearest
                Nothing -> []
    in case list of
           [] -> []
           (x :: xs) -> x :: nearestNeighbourIterate xs x

findNearest :  (Float, Float) -> List (Float, Float) -> Maybe (Float, Float)
findNearest origin coors =
    let distancesFromOrigin = List.map (distance origin) coors
        getNearest points distances nearest = 
            case (points, distances) of
                (p :: ps, d :: ds) -> if abs(d) <= abs(nearest.distance) then getNearest ps ds {nearest | point = p, distance = d}
                             else getNearest ps ds nearest
                _ -> nearest.point
    in case (coors, distancesFromOrigin) of
           (c :: cs, d :: ds) -> Just <| getNearest cs ds { point = c , distance = d}
           _ -> Nothing

removeMatching : List a -> a -> List a
removeMatching list val = 
    let removeAcc list0 accLeft =
            case list0 of
                (x :: xs) -> if x == val then List.reverse accLeft ++ xs
                             else removeAcc xs (x :: accLeft)
                [] -> List.reverse accLeft
    in log ("before: " ++ toString list ++ " after: " ++ toString (removeAcc list [])) removeAcc list []
