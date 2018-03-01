
#include <SDL2/SDL.h>

#include <iostream>
#include <string>
#include <math.h>

#include "sol.hpp"
#include "clock.hpp"
#include "camera.hpp"


//Screen dimension constants
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

void print_stuff()
{
	std::cout << "a" << std::endl;
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

	bool running = true;

	uint32_t framspersecondmax = 30;
	float dt = 1000.0/framspersecondmax;
	float fps;

	Clock frames_lock{};
	frames_lock.tick();

	while(running)
	{
		
		running = update(dt);

		//draw
		camera.clear();
		camera.push();

		SDL_Delay(5);

		dt = frames_lock.tick();
		fps = frames_lock.getFPS();
	}

	SDL_DestroyWindow(window);
	SDL_Quit();

	/*
	for(int i = 0; i < 100000; ++i)
		std::cout << "a" << std::endl;
		update(0);
	*/

	/* Lua stuff
	lua.open_libraries(sol::lib::base);
	lua.script("print('bark bark bark!')");

	lua["mytype"] = Mine{10};
	lua["v1"] = &Mine::var;


	lua.script("print(v1(mytype))");

	lua.new_usertype<Mine>("Mine",
		sol::constructors<Mine(int)>(),
		"var", &Mine::var
		);

	lua.script("my2type = Mine.new(20)");
	lua.script("print(my2type.var)");

	*/

	/* SDL stuff
	//The window we'll be rendering to
	SDL_Window* window = NULL;
	
	//The surface contained by the window
	SDL_Surface* screenSurface = NULL;

	//Initialize SDL
	if(SDL_Init(SDL_INIT_VIDEO) < 0)
	{
		printf("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
	}
	else
	{
		//Create window
		window = SDL_CreateWindow("SDL Tutorial", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN);
		if(window == NULL)
		{
			printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
		}
		else
		{
			//Get window surface
			screenSurface = SDL_GetWindowSurface(window);

			//Fill the surface white
			SDL_FillRect(screenSurface, NULL, SDL_MapRGB(screenSurface->format, 0xFF, 0xFF, 0xFF));
			
			//Update the surface
			SDL_UpdateWindowSurface(window);

			//Wait two seconds
			SDL_Delay(2000);
		}
	}

	//Destroy window
	SDL_DestroyWindow(window);

	//Quit SDL subsystems
	SDL_Quit();
	*/

	return 0;
}