
#include <SDL2/SDL.h>

#include <iostream>
#include <string>
#include <math.h>

#include "sol.hpp"
#include "clock.hpp"
#include "camera.hpp"
#include "input.hpp"
#include "collision.hpp"


//Screen dimension constants
const int SCREEN_WIDTH = 800;
const int SCREEN_HEIGHT = 600;

void registerUsertypes(sol::state &lua)
{
	lua.new_usertype<Point>("Point",
		"x", &Point::x,
		"y", &Point::y
		);

	lua.new_usertype<Rect>("Rect",
		"x", &Rect::x,
		"y", &Rect::y,
		"w", &Rect::w,
		"h", &Rect::h,
		"r", &Rect::r);


	lua.new_usertype<Lua_Texture>("Lua_Texture");

	lua.new_usertype<KEYSTATE>("KEYSTATE",
		"NONE", sol::readonly(&KEYSTATE::NONE),
		"PRESSED", sol::readonly(&KEYSTATE::PRESSED),
		"HELD", sol::readonly(&KEYSTATE::HELD),
		"RELEASED", sol::readonly(&KEYSTATE::RELEASED)
		);


	lua.new_usertype<Input>("Input",
		"keystates", &Input::keystates,
		"update", &Input::update,
		"getKeyState", &Input::getKeyState
		);

	lua["collide_test"] = &collide;
}


int main( int argc, char* args[] )
{
	sol::state lua;

	lua.open_libraries(sol::lib::base,
					sol::lib::package,
					sol::lib::string,
					sol::lib::table,
					sol::lib::math,
					sol::lib::os,
					sol::lib::io
					);

	registerUsertypes(lua);

	lua.script("require('src.lua.main')");

	sol::function update = lua["update"];

	SDL_Init(SDL_INIT_VIDEO);
	SDL_Window *window = nullptr;
	SDL_Renderer *render = nullptr;
	SDL_Surface *screenSurface = nullptr;


	window = SDL_CreateWindow("Echelon", 
							0, 
							0,
							SCREEN_WIDTH,
							SCREEN_HEIGHT,
							SDL_WINDOW_RESIZABLE | SDL_WINDOW_SHOWN);

	render = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE);
	
	Camera *camera = new Camera(window, render);


	/*
		These enclosures allow drawing to the screen without access to the camera or SDL_Texture directly
		SDL_Texture is an incomplete type and can't be used in the templated sol functions
		Also, using lambdas here so lua doesn't deallocate the camera, which would cause a seg fault
	*/
	lua.set_function("draw_sprite",
		[camera](std::string tn, Rect vpr, Rect lr,
			int x, int y, int w, int h)
		{
			camera->draw_sprite(tn, vpr, lr, x, y, w, h);
		});

	lua.set_function("draw_texture", 
		[camera](SDL_Texture *tgt, Rect tgt_r, std::string t_n, Rect src_r)
		{
			camera->draw_texture(tgt, tgt_r, t_n, src_r);
		});
	
	lua.set_function("init_texture",
		[render](Lua_Texture &l_txt, int w, int h)
		{
			//TODO: release texture first
			l_txt.deleteTexture();

			l_txt.texture = SDL_CreateTexture(render, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, w, h);
		});

	Clock frames_lock{};

	bool running = true;

	uint32_t framspersecondmax = 30;
	float dt = 1000.0/framspersecondmax;
	float fps;

	
	frames_lock.tick();

	while(running)
	{
		camera->clear();
		running &= (bool)update(dt);
		camera->push();

		dt = frames_lock.tick();
		fps = frames_lock.getFPS();
	}

	SDL_DestroyWindow(window);
	SDL_Quit();

	return 0;
}