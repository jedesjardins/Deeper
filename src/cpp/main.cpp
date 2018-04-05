
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
		/*
		"collide", &Rect::collide,
		"resolve", &Rect::resolve,
		"resolveBoth", &Rect::resolveBoth
		);*/

	lua.new_usertype<DrawItemSprite>("DrawItemSprite",
		"texturename", &DrawItemSprite::texturename,
		"framex", &DrawItemSprite::framex,
		"framey", &DrawItemSprite::framey,
		"totalframesx", &DrawItemSprite::totalframesx,
		"totalframesy", &DrawItemSprite::totalframesy,
		"rotation", &DrawItemSprite::rotation,
		"dest", &DrawItemSprite::dest,
		"life", &DrawItemSprite::life
		);

	lua.new_usertype<DrawItemTextBox>("DrawItemTextBox",
		"firstline", &DrawItemTextBox::firstline,
		"secondline", &DrawItemTextBox::secondline,
		"showcontinuecursor", &DrawItemTextBox::showcontinuecursor,
		"x", &DrawItemTextBox::x,
		"y", &DrawItemTextBox::y,
		"w", &DrawItemTextBox::w,
		"h", &DrawItemTextBox::h
		);

	lua.new_usertype<DrawItemOptionBox>("DrawItemOptionBox",
		"x", &DrawItemOptionBox::x,
		"y", &DrawItemOptionBox::y,
		"w", &DrawItemOptionBox::w,
		"h", &DrawItemOptionBox::h
		);

	lua.new_usertype<DrawUISprite>("DrawUISprite",
		"texturename", &DrawUISprite::texturename,
		"x", &DrawUISprite::x,
		"y", &DrawUISprite::y
		);

	lua.new_usertype<DrawUnion>("DrawUnion",
		"rect", &DrawUnion::rect,
		"sprite", &DrawUnion::sprite,
		"textbox", &DrawUnion::textbox,
		"optionbox", &DrawUnion::optionbox,
		"uisprite", &DrawUnion::uisprite
		);

	lua.new_usertype<DrawItem>("DrawItem",
		sol::constructors<DrawItem(int)>(),
		"type", &DrawItem::type,
		"data", &DrawItem::data
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

	lua.new_usertype<DRAWITEMTYPE>("DRAWITEMTYPE",
		"NONE", sol::readonly(&DRAWITEMTYPE::NONE),
		"RECT", sol::readonly(&DRAWITEMTYPE::RECT),
		"SPRITE", sol::readonly(&DRAWITEMTYPE::SPRITE),
		"TEXTBOX", sol::readonly(&DRAWITEMTYPE::TEXTBOX),
		"OPTIONBOX", sol::readonly(&DRAWITEMTYPE::OPTIONBOX)
		);

	lua.new_usertype<Input>("Input",
		"keystates", &Input::keystates,
		"update", &Input::update,
		"getKeyState", &Input::getKeyState
		);

	lua["collide_test"] = &collide;

	lua["delay"] = &SDL_Delay;
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
	
	Camera camera{window, render};
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