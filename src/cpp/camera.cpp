#include "camera.hpp"

/*
std::ostream& operator<<(std::ostream &os, const Rect &rect)
{
    os << rect.x << " " << rect.y << " " << rect.w << " " << rect.h;
    return os;
}

std::ostream& operator<<(std::ostream &os, const Camera &camera)
{
    os << camera.vp.x << " " << camera.vp.y << " " << camera.vp.w << " " << camera.vp.h;
    return os;
}
*/

void center(Rect &rect, const Point &point)
{

}

Point center(const Rect &rect)
{
	return {0, 0};
}

Camera::Camera()
:Camera(nullptr)
{}

Camera::Camera(SDL_Window *window)
:window(window), vp{0, 0, 800, 600}, screenrect{0, 0, 800, 600}, render(nullptr)
{
	if(window)
	{
		this->render = SDL_CreateRenderer(this->window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE);

		int32_t w, h;
		SDL_GetWindowSize(window, &w, &h);
		screenrect.w = w;
		screenrect.h = h;
	}
}

void Camera::position(const Point &position)
{
	center(this->vp, position);
}

Point Camera::position()
{
	return {0, 0};
}

void Camera::dimension(const Point &size)
{

}

Point Camera::dimension()
{
	return {0, 0};
}

void Camera::viewport(const Rect &vp)
{
	this->vp = vp;
}

Rect Camera::viewport()
{
	return this->vp;
}

double Camera::getScale()
{
	return 0.0;
}

void Camera::clear()
{
	SDL_SetRenderDrawColor(this->render, 0x00, 0x00, 0x00, 0xFF);
	SDL_RenderClear(this->render);
}

void Camera::push()
{
	SDL_RenderPresent(this->render);
}

void Camera::drawRect(const Rect &r)
{

}