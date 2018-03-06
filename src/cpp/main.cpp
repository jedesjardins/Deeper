
#include <SDL2/SDL.h>

#include <iostream>
#include <string>
#include <math.h>

#include "sol.hpp"
#include "clock.hpp"
#include "camera.hpp"
#include "input.hpp"


//Screen dimension constants
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

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
		"collide", &Rect::collide,
		"resolve", &Rect::resolve,
		"resolveBoth", &Rect::resolveBoth
		);

	lua.new_usertype<DrawItem>("DrawItem",
		"texturename", &DrawItem::texturename,
		"frame", &DrawItem::frame,
		"frames", &DrawItem::totalframes,
		"destrect", &DrawItem::destrect
		);

	lua.new_usertype<DrawContainer>("DrawContainer",
		"dim", &DrawContainer::dim,
		"objs", &DrawContainer::objs,
		"add", &DrawContainer::add
		);

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
}


int main( int argc, char* args[] )
{
	sol::state lua;

	lua.open_libraries(sol::lib::base,
					sol::lib::package,
					sol::lib::string,
					sol::lib::table,
					sol::lib::math,
					sol::lib::os);

	registerUsertypes(lua);

	lua.script("require('src.lua.main')");

	sol::function update = lua["update"];

	SDL_Init(SDL_INIT_VIDEO);
	SDL_Window *window = nullptr;
	SDL_Surface *screenSurface = nullptr;


	window = SDL_CreateWindow("Echelon", 
							SDL_WINDOWPOS_UNDEFINED, 
							SDL_WINDOWPOS_UNDEFINED,
							SCREEN_WIDTH,
							SCREEN_HEIGHT,
							SDL_WINDOW_RESIZABLE | SDL_WINDOW_SHOWN);
	
	Camera camera{window};
	Clock frames_lock{};

	bool running = true;

	uint32_t framspersecondmax = 30;
	float dt = 1000.0/framspersecondmax;
	float fps;

	
	frames_lock.tick();

	while(running)
	{	
		DrawContainer dc;

		running &= (bool)update(dt, dc);

		camera.clear();
		camera.draw(dc);
		camera.push();

		dt = frames_lock.tick();
		fps = frames_lock.getFPS();
	}

	SDL_DestroyWindow(window);
	SDL_Quit();

	return 0;
}