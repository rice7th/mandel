<div align="center">
  <h1>Mandel</h1>
  A simple mandelbrot explorer in under 300 LoC
</div>

<hr>

> [!TIP]
> build using `cargo run --release`.

<hr>

## Screenshots
![mandel in action](https://github.com/rice7th/mandel/assets/93940240/17b0b9be-ddcc-40e5-9301-ef2b365d2d57)

## Controls
- `W` Move up
- `S` Move down
- `A` Move left
- `D` Move right
- `↑` (up arrow) Increase iterations (default: 1000)
- `↓` (down arrow) Decrease iterations
- `Mouse wheel scroll down`: Decrease movement speed
- `Mouse wheel scroll up`: Increase movement speed
- `E` Zoom in
- `Q` Zoom out

## Acknowledgments:
Inigo Quilez's palette function: https://iquilezles.org/articles/palettes/

## Missing things:
- [ ] Polish (code is very traumatizing in this state)
- [ ] Proper Fp64 support
- [ ] Refine chunk management
- [ ] Anti Aliasing (going for a 2x2 sampling with bicubic interpolation probably)
- [ ] Performance optimizations
