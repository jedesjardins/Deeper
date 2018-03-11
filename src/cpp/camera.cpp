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

	points.push_back({r.x, r.y});
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

	//if (RectA.X1 < RectB.X2 
	//&& RectA.X2 > RectB.X1 &&
    //RectA.Y1 > RectB.Y2 
    //&& RectA.Y2 < RectB.Y1) 

	Rect &r1 = *this;

	return 
		r1.x - r1.w/2 < r2.x + r2.w/2
		&& r1.x + r1.w/2 > r2.x - r2.w/2
		&& r1.y + r1.h/2 > r2.y - r2.h/2
		&& r1.y - r1.h/2 < r2.y + r2.h/2;


	/*
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

	//TODO(James): Is this necessary?
	points = getPoints(r1);

	for(auto it = points.begin(); it != points.end(); ++it)
	{
		if(it->x > r2.x - r2.w/2
			&& it->x < r2.x + r2.w/2
			&& it->y > r2.y - r2.h/2
			&& it->y < r2.y + r2.h/2)
		{
			return true;
		}
	}

	return false;
	*/
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
			p1.x = r1.x - overlap_x/2;
			p2.x = r2.x + overlap_x/2;
		}
		else
		{
			p1.x = r1.x + overlap_x/2;
			p2.x = r2.x - overlap_x/2;
		}
		p1.y = r1.y;
		p2.y = r2.y;
	}
	else
	{
		//undo y motion
		if(r1.y < r2.y)
		{
			p1.y = r1.y - overlap_y/2;
			p2.y = r2.y + overlap_y/2;
		}
		else
		{
			p1.y = r1.y + overlap_y/2;
			p2.y = r2.y - overlap_y/2;
		}
		p1.x = r1.x;
		p2.x = r2.x;
	}
}

void Rect::resolve(const Rect &r2, Point &p)
{
	Rect &r1 = *this;

	double overlap_x, overlap_y;

	calculateOverlap(r1, r2, overlap_x, overlap_y);

	//std::cout << r1.x << " " << r1.w << " " << r2.x << " " << r2.w << "\n";

	//std::cout << overlap_x << " " << overlap_y << std::endl;

	//TODO(James): THIS IS A SLOPPY FIX FOR INTERNAL EDGES
	if(overlap_x == overlap_y)
		overlap_x -= 0.0001;
	
	if(overlap_x < overlap_y)
	{
		if(r1.x < r2.x)
		{
			p.x = r1.x - overlap_x;
		}
		else
		{
			p.x = r1.x + overlap_x;
		}
		p.y = r1.y;
	}
	else
	{
		if(r1.y < r2.y)
		{
			p.y = r1.y - overlap_y;
		}
		else
		{
			p.y = r1.y + overlap_y;
		}
		p.x = r1.x;
	}
}

void DrawContainer::add(DrawItem d)
{
	this->objs.push_back(d);
}

Camera::Camera(SDL_Window *window, SDL_Renderer *render)
:window(window), screenrect{0, 0, 800, 600}, render(render)
{
	SDL_SetRenderDrawBlendMode(this->render, SDL_BLENDMODE_BLEND);

	int32_t w, h;
	SDL_GetWindowSize(window, &w, &h);
	screenrect.w = w;
	screenrect.h = h;
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

		if(it.type == 2)
		{
			DrawItemSprite spr = it.data.sprite;

			if(!this->textures[spr.texturename])
			{
				//std::cout << "loading texture: " << it.texturename << std::endl;
				surface = IMG_Load(("resources/sprites/"+spr.texturename).c_str());

				texture = SDL_CreateTextureFromSurface(this->render, surface);
				this->textures[spr.texturename] = texture;

				SDL_FreeSurface(surface);
			}
			else
				texture = this->textures[spr.texturename];

			uint32_t format;
			int access;
			int w, h;

			SDL_QueryTexture(texture, &format, &access, &w, &h);

			//std::cout << spr.totalframesx << " " << spr.totalframesy <<  std::endl;

			w /= spr.totalframesx;
			int framex = (spr.framex - 1) * w;
			h /= spr.totalframesy;
			int framey = (spr.framey - 1) * h;


			SDL_Rect frame{framex, framey, w, h};

			double scalex = (((double)this->screenrect.w)/(viewport.w*TILE_SIZE));
			double scaley = (((double)this->screenrect.h)/(viewport.h*TILE_SIZE));


			Rect renderRect;
						// world scale * image height * in game scale
			renderRect.w = scalex * w * (spr.dest.w*16/w);
			renderRect.h = scaley * h * (spr.dest.h*16/h);

			renderRect.x = -1*viewport.x*TILE_SIZE*scalex  + (.5 * this->screenrect.w) //get viewport translation to screen
							+ spr.dest.x*TILE_SIZE*scalex 						//add position
							- (.5 * renderRect.w);								//subtract half the width

			renderRect.y = viewport.y*TILE_SIZE*scaley + (.5 * this->screenrect.h) 
							- spr.dest.y*TILE_SIZE*scaley 
							- (.5 * renderRect.h);

			SDL_Rect out{(int)renderRect.x, (int)renderRect.y, (int)renderRect.w, (int)renderRect.h};

			//std::cout << renderRect.x << " " << renderRect.y << std::endl;

			SDL_RenderCopyEx(this->render, texture, &frame, &out, -1*spr.rotation, nullptr, SDL_FLIP_NONE);
		} 
		else if(it.type == 1)
		{
			Rect dest = it.data.rect;

			Rect renderCol;

			double scalex = (((double)this->screenrect.w)/(viewport.w*TILE_SIZE));
			double scaley = (((double)this->screenrect.h)/(viewport.h*TILE_SIZE));

			renderCol.w = dest.w * scalex * TILE_SIZE;
			renderCol.h = dest.h * scaley * TILE_SIZE;

			renderCol.x = -1*viewport.x*TILE_SIZE*scalex + (.5 * this->screenrect.w)
						+ dest.x*TILE_SIZE*scalex
						- (.5 * renderCol.w);

			renderCol.y = viewport.y*TILE_SIZE*scaley + (.5 * this->screenrect.h) 
						- dest.y*TILE_SIZE*scaley 
						- (.5 * renderCol.h);

			SDL_Rect col{(int)renderCol.x, (int)renderCol.y, (int)renderCol.w, (int)renderCol.h};

			SDL_SetRenderDrawColor(this->render, 0x00, 0xFF, 0x00, 0x44);
			SDL_RenderDrawRect(this->render, &col);
			SDL_RenderFillRect(this->render, &col);
		}

		/*
		//
		// DRAW IMAGE
		//

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
		Rect renderRect;
		double scalex = (((double)this->screenrect.w)/(viewport.w*TILE_SIZE));
		double scaley = (((double)this->screenrect.h)/(viewport.h*TILE_SIZE));

		renderRect.w = it.destrect.w * scalex;
		renderRect.h = it.destrect.h * scaley;

		renderRect.x = -1*viewport.x*TILE_SIZE*scalex  + (.5 * this->screenrect.w) //get viewport translation to screen
						+ it.destrect.x*TILE_SIZE*scalex 						//add position
						- (.5 * renderRect.w);								//subtract half the width

		renderRect.y = viewport.y*TILE_SIZE*scaley + (.5 * this->screenrect.h) 
						- it.destrect.y*TILE_SIZE*scaley 
						- (.5 * renderRect.h);

		SDL_Rect out{(int)renderRect.x, (int)renderRect.y, (int)renderRect.w, (int)renderRect.h};

		SDL_RenderCopyEx(this->render, texture, &frame, &out, -1*it.rotation, nullptr, SDL_FLIP_NONE);

		//
		// DRAW COLLISION BOX
		//
		Rect renderCol;

		renderCol.w = it.colrect.w * scalex * TILE_SIZE;
		renderCol.h = it.colrect.h * scaley * TILE_SIZE;

		renderCol.x = -1*viewport.x*TILE_SIZE*scalex + (.5 * this->screenrect.w)
					+ it.colrect.x*TILE_SIZE*scalex
					- (.5 * renderCol.w);

		renderCol.y = viewport.y*TILE_SIZE*scaley + (.5 * this->screenrect.h) 
					- it.colrect.y*TILE_SIZE*scaley 
					- (.5 * renderCol.h);

		SDL_Rect col{(int)renderCol.x, (int)renderCol.y, (int)renderCol.w, (int)renderCol.h};

		SDL_SetRenderDrawColor(this->render, 0x00, 0xFF, 0x00, 0x44);

		SDL_RenderFillRect(this->render, &col);
		*/
		
	}
}

void calculateCollisionOut(const Rect &collision)
{
	SDL_Rect renderRect;

	int w, h;

	w = ((double)collision.w)*16;
	h = ((double)collision.h)*16;

	double scalex = (((double)640)/(20*16));
	double scaley = (((double)480)/(15*16));

	renderRect.w = w * scalex;
	renderRect.h = h * scaley;

	renderRect.x = 320 + collision.x*16*scalex  - (.5 * renderRect.w);

	renderRect.y = 240 - collision.y*16*scaley - (.5 * renderRect.h);
}
