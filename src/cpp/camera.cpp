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



void DrawContainer::add(DrawItem d)
{
	this->objs.push_back(d);
}

void center(Rect &rect, const Point &point)
{

}

Point center(const Rect &rect)
{
	return {0, 0};
}

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
		std::cout << w << " " << h << std::endl;
	}
}

Camera::~Camera()
{
	for(auto it: this->textures)
	{
		SDL_DestroyTexture(it.second);
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

void Camera::draw(DrawContainer &dc)
{	
	SDL_Texture *texture;
	SDL_Surface *surface;

	// world points
	Rect world_dims = dc.dim;

	for(auto it: dc.objs)
	{	
		// get texture
		if(!this->textures[it.texturename])
		{
			std::cout << "loading texture" << std::endl;
			surface = IMG_Load(("resources/sprites/"+it.texturename).c_str());

			texture = SDL_CreateTextureFromSurface(this->render, surface);
			this->textures[it.texturename] = texture;

			SDL_FreeSurface(surface);
		}
		else
			texture = this->textures[it.texturename];

		//get size of image
		uint32_t format;
		int access;
		int w, h;
		SDL_QueryTexture(texture, &format, &access, &w, &h);

		w /= it.totalframes;
		int framex = (it.frame -1) * w;
		
		Rect frame{framex, 0, w, h};

		//scale output
		it.destrect.w *= w;
		it.destrect.h *= h;

		// translate dest rect to 
		Rect renderRect;
		renderRect.w = it.destrect.w * (((float)this->screenrect.w)/world_dims.w);
		renderRect.h = it.destrect.h * (((float)this->screenrect.h)/world_dims.h);
		//			      --   translate world position   --        -- translate output size --
		renderRect.x = world_dims.x + (.5 * this->screenrect.w) + it.destrect.x - (.5 * renderRect.w);
		renderRect.y = world_dims.y + (.5 * this->screenrect.h) - it.destrect.y - (.5 * renderRect.h);

		//std::cout << renderRect.x << " " << renderRect.y << " " 
		//		<< renderRect.w << " " << renderRect.h << std::endl;

		SDL_RenderCopy(this->render, texture, &frame, &renderRect);
	}
}
