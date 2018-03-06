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

std::vector<Point> getPoints(const Rect &r)
{
	std::vector<Point> points;

	points.push_back({r.x - r.w/2, r.y - r.h/2});
	points.push_back({r.x + r.w/2, r.y - r.h/2});
	points.push_back({r.x - r.w/2, r.y + r.h/2});
	points.push_back({r.x + r.w/2, r.y + r.h/2});
	points.push_back({r.x, r.y - r.h/2});
	points.push_back({r.x, r.y + r.h/2});
	points.push_back({r.x - r.w/2, r.y});
	points.push_back({r.x + r.w/2, r.y});

	return points;
}

bool Rect::collide(const Rect &r2)
{
	Rect &r1 = *this;

	std::vector<Point> points = getPoints(r2);

	for(auto it = points.begin(); it != points.end(); ++it)
	{
		if(it->x > r1.x - r1.w/2
			&& it->x < r1.x + r1.w/2
			&& it->y > r1.y - r1.h/2
			&& it->y < r1.y + r1.h/2)
		{
			return true;
		}
	}

	return false;
}

void calculateOverlap(const Rect &r1, const Rect &r2, double &overlap_x, double &overlap_y)
{
	if(r1.x < r2.x)
	{
		overlap_x = (r1.x + r1.w/2) - (r2.x - r2.w/2);
	}
	else
	{
		overlap_x = (r2.x + r2.w/2) - (r1.x - r1.w/2);
	}

	if(r1.y < r2.y)
	{
		overlap_y = (r1.y + r1.h/2) - (r2.y - r2.h/2);
	}
	else
	{
		overlap_y = (r2.y + r2.h/2) - (r1.y - r1.h/2);
	}
}

void Rect::resolveBoth(const Rect &r2, Point &p1, Point &p2)
{
	Rect &r1 = *this;

	//calculate overlap in each dimension
	double overlap_x, overlap_y;

	calculateOverlap(r1, r2, overlap_x, overlap_y);

	if (overlap_x < overlap_y)
	{
		//undo x motion
		if(r1.x < r2.x)
		{
			p1.x = r1.x + r1.w/2 - overlap_x/2;
			p2.x = r2.x + r2.w/2 + overlap_x/2;
		}
		else
		{
			p1.x = r1.x + r1.w/2 + overlap_x/2;
			p2.x = r2.x + r2.w/2 - overlap_x/2;
		}
		p1.y = r1.y + r1.h/2;
		p2.y = r2.y + r2.h/2;
	}
	else
	{
		//undo y motion
		if(r1.y < r2.y)
		{
			p1.y = r1.y + r1.h/2 - overlap_y/2;
			p2.y = r2.y + r2.h/2 + overlap_y/2;
		}
		else
		{
			p1.y = r1.y + r1.h/2 + overlap_y/2;
			p2.y = r2.y + r2.h/2 - overlap_y/2;
		}
		p1.x = r1.x + r1.w/2;
		p2.x = r2.x + r2.w/2;
	}
}

void Rect::resolve(const Rect &r2, Point &p)
{
	Rect &r1 = *this;

	double overlap_x, overlap_y;

	calculateOverlap(r1, r2, overlap_x, overlap_y);

	if (overlap_x < overlap_y)
	{
		//undo x motion
		if(r1.x < r2.x)
		{
			p.x = r1.x + r1.w/2 - overlap_x;
		}
		else
		{
			p.x = r1.x + r1.w/2 + overlap_x;
		}
		p.y = r1.y + r1.h/2;
	}
	else
	{
		//undo y motion
		if(r1.y < r2.y)
		{
			p.y = r1.y + r1.h/2 - overlap_y;
		}
		else
		{
			p.y = r1.y + r1.h/2 + overlap_y;
		}
		p.x = r1.x + r1.w/2;
	}
}

void DrawContainer::add(DrawItem d)
{
	this->objs.push_back(d);
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
			//std::cout << "loading texture: " << it.texturename << std::endl;
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
		double scalex = (((double)this->screenrect.w)/(viewport.w*TILE_SIZE));
		double scaley = (((double)this->screenrect.h)/(viewport.h*TILE_SIZE));

		renderRect.w = it.destrect.w * scalex;
		renderRect.h = it.destrect.h * scaley;

		renderRect.x = -1*viewport.x*TILE_SIZE*scalex  + (.5 * this->screenrect.w) 
						+ it.destrect.x*TILE_SIZE*scalex 
						- (.5 * renderRect.w);

		renderRect.y = viewport.y*TILE_SIZE*scaley + (.5 * this->screenrect.h) 
						- it.destrect.y*TILE_SIZE*scaley 
						- (.5 * renderRect.h);

		SDL_RenderCopy(this->render, texture, &frame, &renderRect);
	}
}
