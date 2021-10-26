# Brain - A Nerves Livebook

## About

Brain is a desk gadget which displays a random Kindle highlight from my [notes](https://github.com/zorbash/notes) every 25 minutes.

Read the blogpost https://zorbash.com/post/elixir-nerves-pomodoro-timer/

See https://github.com/livebook-dev/nerves_livebook for setup instructions.

![brain](https://zorbash.com/images/posts/elixir_nerves_pomodoro/live_brain.webp)

### Refreshing the Screen

Run the following either from within a notebook:

```elixir
send :main_scene, :update
```

or ssh:

```
ssh livebook@nerves.local 'send :main_scene, :update'
```

### Searching Notes

See: https://gist.github.com/zorbash/aff21ac049a0c9fdba5016814dfda3aa

## License

See: LICENSE
