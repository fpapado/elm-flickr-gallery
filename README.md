# Elm Gallery for Flickr
This project was created to demonstrated Elm Tasks and their relation to the revamped elm-lang/http library in 0.18.

The application tries to find a user's id by their username, and then get all their photos.

These are the main steps that I came up with for this version of Elm:
 - `Http.send` now perform the task described in the request and sends a message on success. The message has the `Result` type, so the `Ok`, and `Err` cases have to be handled (cf. two success/fail messages in 0.17).
 - In order to chain tasks, we use `Task.andThen`;
   - `Task.andThen` works, well, with `Task`s.
   - Thus, `Http.toTask` is called on each `Request` `Http.get`[\[1\]](http://package.elm-lang.org/packages/elm-lang/http/1.0.0/Http#toTask)
   - The tasks are then linked by piping into `Task.andThen`, which now has its arguments flipped. [\[2\]](https://github.com/elm-lang/elm-platform/blob/master/upgrade-docs/0.18.md#backticks-and-andthen)
 - `Task.perform` is now only for tasks that can't fail [\[3\]](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Task#perform)
  - `Task.attempt` is now used for Tasks that can fail [\[4\]](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Task#attempt). The message sent also handles `Result` type's `Ok` and `Err`.
    - You can see how this aligns with `Http.send`.

In the example, note that there is a separate function `getUserAndPhotos` that handles `Http.Request` functions coalesced into Tasks.
This allows each function to be used individually, as well as more specifically through `Http.send`, if required.

## Further work:
  - Consider how to print separate error messages for each stage
    - "could not find user"
    - "could not load photos"
  - Similarly, how to convert/map Decode pipeline errors into human-readable ones

## References
*Flickr API use inspired by:*
[https://github.com/toastal/elm-flickr-photo-gallery-demo](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Task#attempt)

[Elm Task Docs](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Task)

[Elm Http Docs](http://package.elm-lang.org/packages/elm-lang/http/latest)

