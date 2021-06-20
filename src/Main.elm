-- Used as a guide
-- source: https://github.com/PaackEng/elm-google-maps/blob/2.1.0/examples/src/Main.elm
module Main exposing (..)

import Browser
import GoogleMaps.Map as Map
import GoogleMaps.Marker as Marker exposing (Marker)
import GoogleMaps.Polygon as Polygon exposing (Polygon)
import Html exposing (Html, button, div, h1, text, input)
import Html.Attributes exposing (src, style, class, placeholder)
import Html.Events exposing (onClick, onInput)
import Debug exposing (toString, log)
import TSPalgorithms exposing (nearestNeighbour)

type alias Model =
    {
    mapType : Map.MapType,
    googleMapKey : String,
    coordinates : List (Float, Float),
    latitudeInput : String,
    longitudeInput : String
    }

init : String -> (Model, Cmd Msg)
init key =
    ({
    mapType = Map.roadmap,
    -- configuration 'key' is passed from environment variable
    googleMapKey = key,
    coordinates =  
         -- greedy solution
         [(49.2270476,-122.9751678),(49.283964,-122.8928987),(49.283964,-122.89),(49.283964,-122.8),(49.283964,-122.78),(49.28,-122.78),(49.284,-122.77),(49.3,-122.788),(49,-122.76)],
        -- optimal solution
        --[(49.2270476,-122.9751678),(49.283964,-122.8928987),(49.283964,-122.89),(49.283964,-122.8),(49.3,-122.788),(49.283964,-122.78),(49.28,-122.78),(49.284,-122.77),(49,-122.76)],
    latitudeInput = "",
    longitudeInput = ""
    }, Cmd.none)


type Msg 
    = Coordinates 
    | LatitudeInput String
    | LongitudeInput String
    | RemoveAll


-- Add a new coordinate if only both convert to Float
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LatitudeInput lat -> ({model | latitudeInput = lat}, Cmd.none)
        LongitudeInput lng -> ({model | longitudeInput = lng}, Cmd.none)
        Coordinates -> (case (String.toFloat model.latitudeInput, String.toFloat model.longitudeInput) of
                            (Just lat, Just lng) ->  
                                let optimized = nearestNeighbour (List.append model.coordinates [(lat, lng)])
                                in {model | coordinates = optimized}
                            _ -> model
                            , Cmd.none)
        RemoveAll -> ({model | coordinates = []}, Cmd.none)

googleMapView : Model -> Html Msg
googleMapView {mapType, googleMapKey, coordinates} =
    Map.init googleMapKey
        |> Map.withMapType mapType
        |> Map.withDefaultUIControls False
        |> Map.withFitToMarkers True -- fit all markers in a map
        |> Map.withMarkers (markers coordinates)
        --|> Map.withCenter 49.283964 -122.8928987
        |> Map.withPolygons [tracePath coordinates]
        |> Map.toHtml

-- Create markers based on the coordinates
markers : List (Float, Float) -> List (Marker Msg)
markers coordinates = List.map (\(lat, lng) -> Marker.init lat lng) coordinates

-- Trace a closed path where the first and last points are connected                      
tracePath : List (Float, Float) -> Polygon Msg
tracePath coordinates = 
    Polygon.init coordinates
        |> Polygon.withStrokeColor "black"
        |> Polygon.withClosedMode

view : Model -> Html Msg
view model =
    div [class "map-container", style "height" "400px"]
        [
        googleMapView model,
        -- Keep track of changes to input fields
        input [placeholder "Enter latitude...", onInput LatitudeInput] [],
        input [placeholder "Enter longitude...", onInput LongitudeInput] [],
        -- Add latitude and longitude points to the coordinates
        button [onClick Coordinates] [text "Add point"],
        -- Remove all coordinates
        button [onClick RemoveAll] [text "Remove all coordinates"],
        -- Display coordinates
        div [] [text (toString model.coordinates) ]
        ]

main : Program String Model Msg
main =
    Browser.element
        {
            view = view,
            init = init,
            update = update,
            subscriptions = always Sub.none
        }
