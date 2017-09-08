# Elm Gallery for Flickr
This project was initially created to demonstrate Elm Tasks and their relation to the revamped elm-lang/http library in 0.18.

After that, it is being modified to serve as an example of:
  - [ ] RemoteData modelling
  - [ ] Error messages
  - [X] Quick grid layout,
    - [ ] with fallback

See `todo.md` for more :)

## Chaining Tasks
The application tries to find a user's id by their username, and then gets all their photos.

These are the main steps that I came up with for this version of Elm:
 - `Http.send` now performs the task described in the request and sends a message on success. The message has the `Result` type, so the `Ok`, and `Err` cases have to be handled (cf. two success/fail messages in 0.17).
 - In order to chain tasks, we use `Task.andThen`;
   - `Task.andThen` uses, as you can imagine, `Task`s.
   - Thus, `Http.toTask` can be called on each `Request` `Http.get`. [\[1\]](http://package.elm-lang.org/packages/elm-lang/http/1.0.0/Http#toTask)
   - The tasks are then chained by piping into `Task.andThen`, which after 0.18 has its arguments flipped. [\[2\]](https://github.com/elm-lang/elm-platform/blob/master/upgrade-docs/0.18.md#backticks-and-andthen)
 - `Task.perform` is now only used for tasks that can't fail. [\[3\]](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Task#perform)
  - `Task.attempt` is now used for Tasks that can fail [\[4\]](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Task#attempt). The message sent also handles the `Result` type's `Ok` and `Err` cases.
    - You can see how this aligns with `Http.send`.

In the example, note that there is a separate function `findUserAndPhotos` that internally uses the declared `Http.Request` functions coalesced into Tasks.
This allows each `Http.Request` (`findUserId`, `getPicturesByUID`) to be used either as a task individually or through the new `Http.send`

## API Key
If you want to try this out on your own machine, you would need to add an API key, as string, in the respective parts of `findUserId` and `getPicturesByUID`.
[You can do this via the flickr website](https://www.flickr.com/services/api/misc.api_keys.html).

## Running
### Development
If you don't already have `elm` and `elm-live`:

```shell
npm install -g elm elm-live
```

Then, to build everything:

```shell
elm-live --output=elm.js src/Main.elm --open --debug
```

### Deployment
Serve `index.html` and `elm.js` however you want :)

## References
*Flickr API use inspired by:*
[https://github.com/toastal/elm-flickr-photo-gallery-demo](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Task#attempt)

[Elm Task Docs](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Task)

[Elm Http Docs](http://package.elm-lang.org/packages/elm-lang/http/latest)

[Learning CSS Grids](http://varun.ca/css-grid/)

## License

MIT © Fotis Papadogeorgopoulos
