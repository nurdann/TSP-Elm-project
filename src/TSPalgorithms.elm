module TSPalgorithms exposing (..)
import Debug exposing (log, toString)
import Set exposing (Set)
import Dict exposing (Dict)

-- Pythagorean theorem
distance: (Float, Float) -> (Float, Float) -> Float
distance (x1, y1) (x2, y2) = ((x2 - x1)^2 + (y2 - y1)^2)^0.5

distanceTuple (p1, p2) = distance p1 p2

-- Get all possible permutations                         
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

-- A sequence of points are paired if they are consecutive                     
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

--                                
-- Get optimal distance using all possible permutations
--

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

--             
-- Nearest neighbour, pick first element as starting point
--

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
    in removeAcc list []

        
-- Examples        

data0 = [
 (1, 1),
 (2, 230),
 (3, 4),
 (5, 6),
 (3, 200)
 ]

data1 = [(49.2270476,-122.9751678),(49.283964,-122.8928987),(49.283964,-122.89),(49.283964,-122.8),(49.283964,-122.78),(49.284,-122.77),(49.28,-122.78),(49,-122.76),(49.3,-122.788)]

example0 = nearestNeighbour data0
example1 = nearestNeighbour data1
opt1 = optimal data1


--
-- Union-Find datastructure
--

-- Extract the set that has the matching coordinate and the list without the set
findDisjointSetTupleAcc : comparable -> List (Set comparable) -> List (Set comparable) -> (Set comparable, List (Set comparable))
findDisjointSetTupleAcc point list leftSets =
    case list of
        (set :: sets) -> if Set.member point set then (set, List.reverse leftSets ++ sets)
                         else findDisjointSetTupleAcc point sets (set :: leftSets)
        [] -> (Set.empty, leftSets)

findDisjointSetTuple point list = findDisjointSetTupleAcc point list []

inTheSameDisjointSet : comparable -> comparable -> List (Set comparable) -> Bool
inTheSameDisjointSet p q sets =
    let (pSet, _) = findDisjointSetTuple p sets
    in Set.member q pSet                     
                                  
-- Extract two sets that contain the corresponding two coordinates
-- then merge them together and insert to list.
-- If both of them are in the same set, no need to merge
unionDisjointSets : comparable -> comparable -> List (Set comparable) -> List (Set comparable)
unionDisjointSets p q list =
    let (pSet, list_no_p) = findDisjointSetTuple p list
        (qSet, list_no_pq) = findDisjointSetTuple q list_no_p
    in if Set.member q pSet then (pSet :: list_no_p)
       else (Set.union pSet qSet :: list_no_pq)
    
-- Examples

set0 = Set.fromList data0
set1 = Set.insert (2,3) set0
disjointSets0 = [Set.empty, set0, set1]       
findSet0 = findDisjointSetTuple (1,1) disjointSets0
findSet1 = findDisjointSetTuple (2,3) disjointSets0          
union0 = unionDisjointSets (1,1) (2,3) disjointSets0   
    
-- Step 1
-- Kruskal's algorithm for finding minimum spanning tree
-- source: https://en.wikipedia.org/wiki/Kruskal%27s_algorithm#Pseudocode

type alias Node = (Float, Float)
type alias Edge = (Node, Node)        

-- Assume elements in node and edge lists are unique
minSpanTree : List Node -> List Edge -> List Edge
minSpanTree nodes edges =
    let orderedEdges = List.sortBy distanceTuple edges
        disjointSets = List.map Set.singleton nodes
        iterateEdges edges0 sets minSpan =
            case edges0 of
                ((u, v) :: es) ->
                    if not (inTheSameDisjointSet u v sets)
                    then iterateEdges es (unionDisjointSets u v sets)  ((u, v) :: minSpan)
                    else iterateEdges es sets minSpan
                [] -> minSpan
    in iterateEdges orderedEdges disjointSets []

-- Form edges for a complete graph        
edgesForCompleteGraph : List a -> List (a, a)
edgesForCompleteGraph list =
    let getPairs list0 firstPair = List.map (\secondPair -> (firstPair, secondPair)) list0
        recurseGetPairs list1 leftList =
            case (list1) of
                (x :: xs) -> List.append (getPairs (leftList ++ xs) x) (recurseGetPairs xs (leftList ++ [x]))
                [] -> []
    in recurseGetPairs list []
       
-- Examples

data2 = [(0,0), (1,0), (3,1), (2,5)]
edges2 = edgesForCompleteGraph data2
exampleSpanningEdges = minSpanTree data2 edges2

-- Step 2                       
-- Partition nodes into odd and even degree lists based on edges

oddEvenDegreeVertices : List Edge -> (List Node, List Node)
oddEvenDegreeVertices edges =
    let countDegree nodeMap edges0 =
            case edges0 of
                ((u, v) :: es) -> countDegree (incrementMap nodeMap [u, v]) es
                [] -> nodeMap
        (even, odd) = Dict.partition (\k val -> modBy 2 val == 0) (countDegree Dict.empty edges)
        (evenPoints, oddPoints) = (List.map Tuple.first (Dict.toList even), List.map Tuple.first (Dict.toList odd))
    in (evenPoints, oddPoints)
        
incrementMap : Dict comparable Int -> List comparable -> Dict comparable Int
incrementMap nodeMap keys =
    let incrementValue nodeMap0 key =
            case Dict.get key nodeMap0 of
                Just val -> Dict.insert key (val + 1) nodeMap0
                Nothing -> Dict.insert key 1 nodeMap0
    in case keys of
           (k :: ks) -> incrementMap (incrementValue nodeMap k) ks
           [] -> nodeMap
        
-- Input for Step 3                        
-- Induce subgraph, that is get subgraph such that odd degree vertices retain all edges in the original graph

induceSubgraph : List Edge -> List Edge
induceSubgraph edges =
    let -- odd degree points have even number of vertices
        (evenDegreePoints, oddDegreePoints) = oddEvenDegreeVertices edges
        -- filter for edges s.t. both end points are in the vertex set
        induce vertices edges0 subset =
            case edges0 of
                [] -> subset
                ((u, v) :: es) -> if List.member u vertices && List.member v vertices
                                  then induce vertices es ((u, v) :: subset)
                                  else induce vertices es subset
    in induce oddDegreePoints edges []

-- Examples

exampleInduce = induceSubgraph exampleSpanningEdges
