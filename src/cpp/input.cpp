
#include "input.hpp"

bool Input::update()
{
	SDL_Event event;
	KEYSTATE KS;

	bool running = true;

	//transitions
	for(auto it:this->keystates){
		if(it.second == KS.PRESSED)
			this->keystates[it.first] = KS.HELD;
		else if(it.second == KS.RELEASED)
			this->keystates.erase(it.first);
	}

	//set current states
	while(SDL_PollEvent(&event) != 0)
	{
		if(event.type == SDL_QUIT)
			running &= false;
		else if(event.type == SDL_KEYDOWN || event.type == SDL_KEYUP)
		{
			if(event.type == SDL_KEYDOWN 
				&& Input::getKeyState(SDL_GetKeyName(event.key.keysym.sym)) != KS.HELD)
			{
				this->keystates[SDL_GetKeyName(event.key.keysym.sym)] = KS.PRESSED;
			}
			else if(event.type == SDL_KEYUP)
			{
				this->keystates[SDL_GetKeyName(event.key.keysym.sym)] = KS.RELEASED;
			}
			
			if(event.key.keysym.sym == SDLK_ESCAPE)
				running &= false;
		}
	}

	return running;
}

int Input::getKeyState(std::string key)
{
	return this->keystates[key];
}




