# Elm Gallery for Flickr
This project was created to demonstrated Elm Tasks and their relation to the revamped elm-lang/http library in 0.18.

The application tries to find a user's id by their username, and then get all their photos.

These are the main differences now:
 - Http.send now perform the task described in the request and sends a message on success. The message has the Result type, so the Ok, and Err cases have to be handled.
 - In order to chain tasks, however, Task.andThen only works with proper Task functions.
   - Thus, Http.toTask is called on each Http.get component
   - The tasks are then linked by piping into Task.andThen, which now has its arguments flipped. The upside is that it makes the arguments more explicit: ...
 - Task.perform is now only for tasks that can't fail
  - Task.attempt is no used for Tasks that can fail. The message sent also handles Result type's Ok and Err
    - You can see how this aligns with Http.send
