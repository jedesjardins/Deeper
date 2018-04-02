#include "clock.hpp"
#include <iostream>

Clock::Clock(uint32_t starttime)
:lastframetime(starttime)
{}

uint32_t Clock::getTime()
{
	return SDL_GetTicks();
}

float Clock::tick(uint32_t framerate)
{
	float currenttime = this->getTime();
	float elapsedtime = currenttime - this->lastframetime;

	if(framerate == 0)
	{
		this->lastframetime = currenttime;
	}
	else
	{
		float goaldt = 1000.0/framerate;

		uint32_t timetowait = uint32_t(floor(goaldt)) - elapsedtime;

		if(uint32_t(goaldt) > elapsedtime)
		{
			SDL_Delay(timetowait);
			elapsedtime += goaldt;
		}
	}

	/*
	if(this->pastframesqueue.size() == 10)
		this->pastframesqueue.pop_back();
	
	this->pastframesqueue.push_front(elapsedtime);
	this->lastframetime = this->getTime();
	*/

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

