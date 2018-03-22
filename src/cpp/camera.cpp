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

bool Rect::collide(const Rect &r2)
{
	Rect &r1 = *this;

	return 
		r1.x - r1.w/2 < r2.x + r2.w/2
		&& r1.x + r1.w/2 > r2.x - r2.w/2
		&& r1.y + r1.h/2 > r2.y - r2.h/2
		&& r1.y - r1.h/2 < r2.y + r2.h/2;
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

DrawUnion::DrawUnion(){};
DrawUnion::~DrawUnion(){};

DrawItem::DrawItem(int type)
:type(type)
{
	if(type == 1) //Rect
	{
		this->data.rect = Rect();
	}
	else if(type == 2) //Sprite
	{
		this->data.sprite = DrawItemSprite();
	}
	else if(type == 3)
	{
		this->data.textbox = DrawItemTextBox();
	}
	else if(type == 4)
	{
		this->data.optionbox = DrawItemOptionBox();
	}
}

void DrawContainer::add(DrawItem d)
{
	this->objs.push_back(d);
}

GlyphAtlas::GlyphAtlas()
:font(nullptr)
{
	TTF_Init();

	this->font = TTF_OpenFont("resources/basis33.ttf", 35);
}

GlyphAtlas::~GlyphAtlas()
{
	for(auto it: this->glyphs)
	{
		SDL_DestroyTexture(it.second);
	}

	TTF_CloseFont(this->font);
}

SDL_Texture* GlyphAtlas::getGlyph(SDL_Renderer *render, char c)
{
	if(!this->glyphs[c])
	{
		char str[2];
		str[0] = c;
		str[1] = '\0';

		SDL_Color color = {0,0,0};
		SDL_Surface *textSurface = TTF_RenderText_Solid(this->font, str, color);
		this->glyphs[c] = SDL_CreateTextureFromSurface(render, textSurface);

		SDL_FreeSurface(textSurface);

		return this->glyphs[c];
	}
	else
		return this->glyphs[c];
}


Camera::Camera(SDL_Window *window, SDL_Renderer *render)
:window(window), screenrect{0, 0, 800, 600}, render(render), glyphatlas()
{
	IMG_Init(IMG_INIT_PNG);
	
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
		if(it.type == 1)
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
		else if(it.type == 2)
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
		else if (it.type == 3)
		{
			std::string texturename = "border.png";

			if(!this->textures[texturename])
			{
				//std::cout << "loading texture: " << it.texturename << std::endl;
				surface = IMG_Load(("resources/sprites/"+texturename).c_str());

				texture = SDL_CreateTextureFromSurface(this->render, surface);
				this->textures[texturename] = texture;

				SDL_FreeSurface(surface);
			}
			else
				texture = this->textures[texturename];

			DrawItemTextBox box = it.data.textbox;

			int sw, sh;
			SDL_GetWindowSize(this->window, &sw, &sh);


			SDL_Rect frame{0, 0, 10, 10};
			SDL_Rect out;

			int startx = box.x * sw;
			int starty = box.y * sh;
			int width = box.w * sw;
			int height = box.h * sh;

			std::vector<int> xs = {startx, startx+10, startx+width-10};
			std::vector<int> ys = {starty, starty+10, starty+height-10};
			std::vector<int> ws = {10, width-20, 10};
			std::vector<int> hs = {10, height-20, 10};


			for(int i = 0; i < 3; ++i)
			{
				for(int j = 0; j < 3; ++j)
				{
					frame.x = i * 10;
					frame.y = j * 10;

					out.x = xs[i];
					out.y = ys[j];
					out.w = ws[i];
					out.h = hs[j];

					SDL_RenderCopy(this->render, texture, &frame, &out);
				}
			}

			uint32_t format;
			int access;
			int tw, th;

			SDL_Texture *textTexture;

			int linespace = 10;
			int textmaxwidth = width-20-linespace*2;
			int textmaxheight = (height-20-linespace*3)/2;
			int letterheight = textmaxheight;

			SDL_Rect r;
			r.x = startx + 10 + linespace;
			r.y = starty + 10 + linespace;


			for (int i = 0; i < box.firstline.length(); ++i)
			{
				textTexture = this->glyphatlas.getGlyph(this->render, box.firstline[i]);


				SDL_QueryTexture(textTexture, &format, &access, &tw, &th);

				r.w = tw;
				r.h = th;

				if(r.x + r.w > startx + width-10)
					break;

				SDL_RenderCopy(this->render, textTexture, nullptr, &r);

				SDL_SetRenderDrawColor(this->render, 0x00, 0x00, 0x00, 0x22);
				SDL_RenderDrawRect(this->render, &r);

				r.x += r.w;
			}

			//move to start of next line
			r.x = startx + 10 + linespace;
			r.y += r.h + linespace;

			for (int i = 0; i < box.secondline.length(); ++i)
			{
				textTexture = this->glyphatlas.getGlyph(this->render, box.secondline[i]);


				SDL_QueryTexture(textTexture, &format, &access, &tw, &th);

				r.w = tw;
				r.h = th;
				SDL_RenderCopy(this->render, textTexture, nullptr, &r);

				SDL_SetRenderDrawColor(this->render, 0x00, 0x00, 0x00, 0x22);
				SDL_RenderDrawRect(this->render, &r);

				r.x += r.w;
			}

			if(box.showcontinuecursor)
			{
				SDL_Surface *cursorSurface;
				SDL_Texture *cursorTexture;

				if(!this->textures["cursordown.png"])
				{
					//std::cout << "loading texture: " << it.texturename << std::endl;
					cursorSurface = IMG_Load("resources/sprites/cursordown.png");

					cursorTexture = SDL_CreateTextureFromSurface(this->render, cursorSurface);
					this->textures["cursordown.png"] = cursorTexture;

					SDL_FreeSurface(cursorSurface);
				}
				else
					cursorTexture = this->textures["cursordown.png"];

				//draw the cursor

				r.x = 600;
				r.y += r.h - 2;
				r.w = 20;
				r.h = 10;

				SDL_RenderCopy(this->render, cursorTexture, nullptr, &r);
			}
		}
		else if (it.type == 4)
		{
			std::string texturename = "border.png";

			if(!this->textures[texturename])
			{
				//std::cout << "loading texture: " << it.texturename << std::endl;
				surface = IMG_Load(("resources/sprites/"+texturename).c_str());

				texture = SDL_CreateTextureFromSurface(this->render, surface);
				this->textures[texturename] = texture;

				SDL_FreeSurface(surface);
			}
			else
				texture = this->textures[texturename];

			DrawItemOptionBox box = it.data.optionbox;

			int sw, sh;
			SDL_GetWindowSize(this->window, &sw, &sh);

			SDL_Rect frame{0, 0, 10, 10};
			SDL_Rect out;

			int startx = box.x * sw;
			int starty = box.y * sh;
			int width = box.w * sw;
			int height = box.h * sh;

			std::vector<int> xs = {startx, startx+10, startx+width-10};
			std::vector<int> ys = {starty, starty+10, starty+height-10};
			std::vector<int> ws = {10, width-20, 10};
			std::vector<int> hs = {10, height-20, 10};


			for(int i = 0; i < 3; ++i)
			{
				for(int j = 0; j < 3; ++j)
				{
					frame.x = i * 10;
					frame.y = j * 10;

					out.x = xs[i];
					out.y = ys[j];
					out.w = ws[i];
					out.h = hs[j];

					SDL_RenderCopy(this->render, texture, &frame, &out);
				}
			}
		}
	}
}
