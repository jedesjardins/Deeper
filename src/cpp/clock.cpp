#include "clock.hpp"

Clock::Clock(uint32_t starttime)
:lastframetime(starttime)
{}

uint32_t Clock::getTime()
{
	return SDL_GetTicks();
}

uint32_t Clock::tick(uint32_t framerate)
{
	uint32_t currenttime = this->getTime();
	uint32_t elapsedtime = currenttime - this->lastframetime;

	if(framerate == 0)
	{
		this->lastframetime = currenttime;
	}
	else
	{
		float goaldt = 1000.0/framerate;

		uint32_t timetowait = uint32_t(goaldt) - elapsedtime;

		if(uint32_t(goaldt) > elapsedtime)
			SDL_Delay(timetowait);
	}

	if(this->pastframesqueue.size() == 10)
		this->pastframesqueue.pop_back();
	
	this->pastframesqueue.push_front(elapsedtime);

	return elapsedtime;
}

float Clock::getFPS()
{
	float averageelapsedtime = 0.0;
	for(auto it = this->pastframesqueue.begin(); 
		it != this->pastframesqueue.end(); 
		++it)
	{
		averageelapsedtime += *it;
	}
	return 1000.0/(averageelapsedtime/this->pastframesqueue.size());
}

