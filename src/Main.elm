module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, src)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Task exposing (andThen)


-- Model


type alias Model =
    { pictures : List Picture
    , username : String
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
            ( { model | pictures = result }, Cmd.none )

        AddNewPhotos (Err _) ->
            ( model, Cmd.none )

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
                ++ "&api_key=777643948c3de563bdf7190a21ba6373"
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
                ++ "&api_key=777643948c3de563bdf7190a21ba6373"
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
    div []
        [ h1 [] [ text "Flickr Gallery" ]
        , input [ placeholder "Username", onInput EditUsername ] []
        , button [ onClick (FindPhotosByUsername) ] [ text "Get photos!" ]
        , div []
            (List.map imageView model.pictures)
        ]


imageView : Picture -> Html Msg
imageView picture =
    img [ src picture.url ] []



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Init


init : ( Model, Cmd Msg )
init =
    ( { pictures = [], username = "" }, Cmd.none )


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
