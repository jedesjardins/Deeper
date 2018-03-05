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

SDL_Rect Rect::convert()
{
	return SDL_Rect{
		(int)floor(this->x), 
		(int)floor(this->y),
		(int)floor(this->w),
		(int)floor(this->h)
		};
}

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
:window(window), screenrect{0, 0, 800, 600}, render(nullptr)
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

Camera::~Camera()
{
	for(auto it: this->textures)
	{
		SDL_DestroyTexture(it.second);
	}
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

void Camera::draw(DrawContainer &dc)
{	
	SDL_Texture *texture;
	SDL_Surface *surface;

	// world points
	Rect viewport = dc.dim;

	for(auto it: dc.objs)
	{	
		// get texture
		if(!this->textures[it.texturename])
		{
			std::cout << "loading texture: " << it.texturename << std::endl;
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
		
		SDL_Rect frame{framex, 0, w, h};

		//scale output
		it.destrect.w *= w;
		it.destrect.h *= h;

		// translate dest rect to 
		SDL_Rect renderRect;
		renderRect.w = it.destrect.w * (((float)this->screenrect.w)/viewport.w);
		renderRect.h = it.destrect.h * (((float)this->screenrect.h)/viewport.h);
		//			      --   translate world position   --        -- translate output size --
		renderRect.x = viewport.x + (.5 * this->screenrect.w) + it.destrect.x - (.5 * renderRect.w);
		renderRect.y = viewport.y + (.5 * this->screenrect.h) - it.destrect.y - (.5 * renderRect.h);

		//std::cout << renderRect.x << " " << renderRect.y << " " 
		//		<< renderRect.w << " " << renderRect.h << std::endl;

		SDL_RenderCopy(this->render, texture, &frame, &renderRect);
	}
}
