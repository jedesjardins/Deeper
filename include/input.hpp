#ifndef INPUT_H_
#define INPUT_H_

#include <SDL2/SDL.h>

#include <string>
#include <unordered_map>

#include "sol.hpp"

struct KEYSTATE {
	int NONE = 0;
	int RELEASED = 1;
	int PRESSED = 2;
	int HELD = 3;
};

class Input
{
public:
	int x = 0;
	int y = 0;
	std::unordered_map<std::string, int> keystates;

	bool update();
	int getKeyState(std::string);
};

#endif