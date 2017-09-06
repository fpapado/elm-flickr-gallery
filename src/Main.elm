module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, rel, src, style)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Task exposing (andThen)


apiKey =
    "777643948c3de563bdf7190a21ba6373"



-- Model


type alias Model =
    { pictures : List Picture
    , username : String
    , error : Maybe Http.Error
    }


type alias Picture =
    { id : String
    , url : String
    , title : String
    }



-- Update


type Msg
    = EditUsername String
    | AddNewPhotos (Result Http.Error (List Picture))
    | FindPhotosByUsername


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FindPhotosByUsername ->
            ( model, findUserAndPhotos model.username )

        AddNewPhotos (Ok result) ->
            ( { model | pictures = result, error = Nothing }, Cmd.none )

        AddNewPhotos (Err error_) ->
            ( { model | error = Just error_ }, Cmd.none )

        EditUsername username_ ->
            ( { model | username = username_ }, Cmd.none )


findUserAndPhotos : String -> Cmd Msg
findUserAndPhotos username =
    let
        chain =
            Http.toTask (findUserId username)
                |> Task.andThen (\user_id -> (Http.toTask (getPicturesByUID user_id)))
    in
        Task.attempt AddNewPhotos chain


findUserId : String -> Http.Request String
findUserId username =
    let
        url =
            "https://api.flickr.com/services/rest/"
                ++ "?method=flickr.people.findByUsername"
                ++ "&api_key="
                ++ apiKey
                ++ "&username="
                ++ username
                ++ "&format=json"
                ++ "&nojsoncallback=1"
    in
        Http.get url userIdDecoder


userIdDecoder : Decoder String
userIdDecoder =
    Decode.at [ "user", "id" ] (Decode.string)


getPicturesByUID : String -> Http.Request (List Picture)
getPicturesByUID user_id =
    let
        url =
            "https://api.flickr.com/services/rest/"
                ++ "?method=flickr.people.getPhotos"
                ++ "&api_key="
                ++ apiKey
                ++ "&user_id="
                ++ user_id
                ++ "&format=json"
                ++ "&extras=url_q"
                ++ "&nojsoncallback=1"
                ++ "&per_page=100"
    in
        Http.get url picturesDecoder


picturesDecoder : Decoder (List Picture)
picturesDecoder =
    let
        decodePicture =
            decode Picture
                |> required "id" Decode.string
                |> optional "url_q" Decode.string ""
                |> optional "title" Decode.string ""
    in
        Decode.at [ "photos", "photo" ] (Decode.list decodePicture)



-- View


view : Model -> Html Msg
view model =
    div [ class "mw7-ns pa3 center" ]
        [ node "link" [ rel "stylesheet", href "https://unpkg.com/tachyons@4.6.1/css/tachyons.min.css" ] []
        , h1 [ class "f2 f1-ns tc sans-serif navy" ] [ text "Elm Flickr Gallery" ]
        , div [ class "tc mb4" ]
            [ input [ placeholder "Username", onInput EditUsername, class "input-reset dib mr2 mt2 pa2 ba bw1 b--blue black-80" ] []
            , button [ onClick (FindPhotosByUsername), class "dib pa2 mt2 pointer ba bw1 b--dark-pink bg-animate hover-bg-dark-pink hover-white black-80 bg-white" ]
                [ text "Get photos!" ]
            ]
        , errorView model.error
        , div [ class "flex flex-wrap" ]
            (List.map imageView model.pictures)
        ]


imageView : Picture -> Html Msg
imageView picture =
    div [ class "ph2 mb3", style [ ( "flex", "0 0 25%" ) ] ]
        [ img [ src picture.url, class "w-100" ] []
        ]


errorView : Maybe Http.Error -> Html Msg
errorView errorHttpMaybe =
    div []
        [ case errorHttpMaybe of
            Just errorHttp ->
                text <| toString errorHttp

            Nothing ->
                text ""
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Init


init : ( Model, Cmd Msg )
init =
    ( { pictures = [], username = "", error = Nothing }, Cmd.none )


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
