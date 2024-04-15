use miniquad::*;

#[repr(C)]
struct Vec2 {
    x: f32,
    y: f32,
}
#[repr(C)]
struct Vertex {
    pos: Vec2,
    uv: Vec2,
}

struct Stage {
    ctx: Box<dyn RenderingBackend>,

    pipeline: Pipeline,
    bindings: Bindings,
    
    pos: (f32, f32),
    chunk: (u32, u32),
    keys: u32,
    zoom: (u32, u32),
    zoom_speed: f32,
    move_speed: f32,
    iter: u32,
    frames: u32
}

impl Stage {
    pub fn new() -> Stage {
        let mut ctx: Box<dyn RenderingBackend> = window::new_rendering_backend();

        #[rustfmt::skip]
        let vertices: [Vertex; 4] = [
            Vertex { pos : Vec2 { x: -1.0, y: -1.0 }, uv: Vec2 { x: 0., y: 0. } },
            Vertex { pos : Vec2 { x:  1.0, y: -1.0 }, uv: Vec2 { x: 1., y: 0. } },
            Vertex { pos : Vec2 { x:  1.0, y:  1.0 }, uv: Vec2 { x: 1., y: 1. } },
            Vertex { pos : Vec2 { x: -1.0, y:  1.0 }, uv: Vec2 { x: 0., y: 1. } },
        ];
        let vertex_buffer = ctx.new_buffer(
            BufferType::VertexBuffer,
            BufferUsage::Immutable,
            BufferSource::slice(&vertices),
        );

        let indices: [u16; 6] = [0, 1, 2, 0, 2, 3];
        let index_buffer = ctx.new_buffer(
            BufferType::IndexBuffer,
            BufferUsage::Immutable,
            BufferSource::slice(&indices),
        );

        let bindings = Bindings {
            vertex_buffers: vec![vertex_buffer],
            index_buffer: index_buffer,
            images: vec![],
        };

        let shader = ctx
            .new_shader(
                ShaderSource::Glsl {
                        vertex: shader::VERTEX,
                        fragment: shader::FRAGMENT,
                },
                shader::meta(),
            )
            .unwrap();

        let pipeline = ctx.new_pipeline(
            &[BufferLayout::default()],
            &[
                VertexAttribute::new("in_pos", VertexFormat::Float2),
                VertexAttribute::new("in_uv", VertexFormat::Float2),
            ],
            shader,
            PipelineParams::default(),
        );

        Stage {
            pipeline,
            bindings,
            ctx,
            pos: (0., 0.),
            chunk: (2147483648, 2147483648),
            keys: 0,
            zoom: (0, 1),
            zoom_speed: 0.0,
            move_speed: 0.0,
            iter: 1000,
            frames: 0,
        }
    }

    fn add_zoom(&mut self, z: u64, neg: bool) {
        if neg {
            self.zoom = unsafe { std::mem::transmute::<u64, (u32, u32)>( std::mem::transmute::<(u32, u32), u64>(self.zoom) - z ) };
        } else {
            self.zoom = unsafe { std::mem::transmute::<u64, (u32, u32)>( std::mem::transmute::<(u32, u32), u64>(self.zoom) + z ) };
        }
        
    }
}

impl EventHandler for Stage {
    fn update(&mut self) {}

    fn mouse_wheel_event(&mut self, _x: f32, y: f32) {
        if y > 0.0 {
            self.move_speed += 0.1
        } else {
            self.move_speed -= 0.1
        }
    }

    fn key_down_event(&mut self, keycode: KeyCode, _keymods: KeyMods, _repeat: bool) {
        if keycode == KeyCode::W { // forward
            self.keys |= 0b000001;
        }
        if keycode == KeyCode::A { // left
            self.keys |= 0b000010;
        }
        if keycode == KeyCode::S { // backwards
            self.keys |= 0b000100;
        }
        if keycode == KeyCode::D { // right
            self.keys |= 0b001000;
        }
        if keycode == KeyCode::E { // Zoom in
            self.keys |= 0b010000;
        }
        if keycode == KeyCode::Q { // Zoom out
            self.keys |= 0b100000;
        }

        if keycode == KeyCode::Up { // Iter +
            self.keys |= 0b1000000;
        }
        if keycode == KeyCode::Down { // Iter -
            self.keys |= 0b10000000;
        }
    }

    fn key_up_event(&mut self, keycode: KeyCode, _keymods: KeyMods) {
        if keycode == KeyCode::W { // forward
            self.keys &= !0b000001;
        }
        if keycode == KeyCode::A { // left
            self.keys &= !0b000010;
        }
        if keycode == KeyCode::S { // backwards
            self.keys &= !0b000100;
        }
        if keycode == KeyCode::D { // right
            self.keys &= !0b001000;
        }
        if keycode == KeyCode::E { // Zoom in
            self.keys &= !0b010000;
        }
        if keycode == KeyCode::Q { // Zoom out
            self.keys &= !0b100000;
        }

        if keycode == KeyCode::Up { // Iter +
            self.keys &= !0b1000000;
        }
        if keycode == KeyCode::Down { // Iter -
            self.keys &= !0b10000000;
        }
    }

    fn draw(&mut self) {
        self.ctx.begin_default_pass(Default::default());

        self.frames += 1;
        dbg!(self.frames);

        if self.keys & 0b000001 != 0 { // forward
            self.pos.1 -= f32::exp2(self.move_speed);
            if self.pos.1 < 0.0 {
                self.chunk.1 -= 1;
            }
        }
        if self.keys & 0b000010 != 0 { // left
            self.pos.0 += f32::exp2(self.move_speed);
            if self.pos.0 > 1.0 {
                self.chunk.0 += 1;
            }
        }
        if self.keys & 0b000100 != 0 { // backwards
            self.pos.1 += f32::exp2(self.move_speed);
            if self.pos.1 > 1.0 {
                self.chunk.1 += 1;
            }
        }
        if self.keys & 0b001000 != 0 { // right
            self.pos.0 -= f32::exp2(self.move_speed);
            if self.pos.0 < 0.0 {
                self.chunk.0 -= 1;
            }
        }
        if self.keys & 0b010000 != 0 { // zoom in
            self.add_zoom(1, false);
        }
        if self.keys & 0b100000 != 0 { // zoom out
            self.add_zoom(1, true);
        }
        if self.keys & 0b1000000 != 0 { // zoom in
            self.iter += 1;
        }
        if self.keys & 0b10000000 != 0 { // zoom out
            self.iter = self.iter.saturating_sub(1);
        }


        self.ctx.apply_pipeline(&self.pipeline);
        self.ctx.apply_bindings(&self.bindings);
        self.ctx
            .apply_uniforms(UniformsSource::table(&shader::Uniforms {
                res: window::screen_size(),
                pos: self.pos,
                chunk: self.chunk,
                zoom: self.zoom,
                speed: self.move_speed,
                iter: self.iter
            }));
        self.ctx.draw(0, 6, 1);
        self.ctx.end_render_pass();

        self.ctx.commit_frame();
    }
}

fn main() {
    let mut conf = conf::Conf::default();
    conf.platform.apple_gfx_api = conf::AppleGfxApi::OpenGl;

    miniquad::start(conf, move || Box::new(Stage::new()));
}

mod shader {
    use miniquad::*;

    pub const VERTEX: &str = include_str!("vert.glsl");

    pub const FRAGMENT: &str = include_str!("frag.glsl");

    pub fn meta() -> ShaderMeta {
        ShaderMeta {
            images: vec![],
            uniforms: UniformBlockLayout {
                uniforms: vec![UniformDesc::new("res", UniformType::Float2),
                               UniformDesc::new("pos", UniformType::Float2),
                               UniformDesc::new("chunk", UniformType::Int2),
                               UniformDesc::new("zoom", UniformType::Int2),
                               UniformDesc::new("speed", UniformType::Float1),
                               UniformDesc::new("iter", UniformType::Int1),]
            },
        }
    }

    #[repr(C)]
    pub struct Uniforms {
        pub res: (f32, f32),
        pub pos: (f32, f32),
        pub chunk: (u32, u32),
        pub zoom: (u32, u32),
        pub speed: f32,
        pub iter: u32
    }
}