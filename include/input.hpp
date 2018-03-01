#ifndef INPUT_H_
#define INPUT_H_

#include <SDL2/SDL.h>

#include <string>
#include <unordered_map>

#include "sol.hpp"

struct KEYSTATE {
	int NONE = 0;
	int PRESSED = 1;
	int HELD = 2;
	int RELEASED = 3;
};

class Input
{
public:
	std::unordered_map<std::string, int> keystates;

	bool update();
	int getKeyState(std::string);
};

#endif