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

type alias Model =
    {
    mapType : Map.MapType,
    googleMapKey : String,
    coordinates : List (Float, Float)
    }

init : String -> (Model, Cmd Msg)
init key =
    ({
    mapType = Map.roadmap,
    googleMapKey = key,
    coordinates =  
        [ (49.2270476,-122.9751678),
          (49.283964,-122.8928987)
        ]
    }, Cmd.none)


type Msg 
    = DrawCoordinates (List (Float, Float))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        _ -> (model, Cmd.none)

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

markers : List (Float, Float) -> List (Marker Msg)
markers coordinates = List.map (\(lat, lng) -> Marker.init lat lng) coordinates

tracePath : List (Float, Float) -> Polygon Msg
tracePath coordinates = 
    Polygon.init coordinates
        |> Polygon.withStrokeColor "black"
        |> Polygon.withClosedMode

view : Model -> Html Msg
view model =
    let d0 = 0
    in div [class "map-container", style "height" "400px"]
        [
        googleMapView model,
        input [placeholder "Enter latitude...", onInput ] [],
        input [placeholder "Enter longitude..."] [],
        button [onClick AddCoordinate] [text "Add point"],
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
