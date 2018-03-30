#ifndef CLOCK_H_
#define CLOCK_H_

#include <SDL2/SDL.h>
#include <list>
#include <math.h>

class Clock
{
private:
	float lastframetime;
	std::list<float> pastframesqueue;

public:
	Clock(uint32_t starttime = 0);

	uint32_t getTime();
	float tick(uint32_t framerate = 0);
	float getFPS();
};

#endif