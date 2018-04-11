#include "camera.hpp"

Lua_Texture::Lua_Texture()
:texture(nullptr)
{
	
}

Lua_Texture::~Lua_Texture()
{
	this->deleteTexture();
}

void Lua_Texture::deleteTexture()
{
	if(this->texture)
	{	
		SDL_DestroyTexture(this->texture);
		this->texture = nullptr;
	}
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
	SDL_SetRenderDrawColor(this->render, 0x22, 0x22, 0x22, 0xFF);
	SDL_RenderClear(this->render);
}

void Camera::push()
{
	SDL_RenderPresent(this->render);
}

void Camera::draw_texture(SDL_Texture *target, Rect target_rect, 
	std::string texturename, Rect src_rect)
{
	SDL_Texture *texture;
	SDL_Surface *surface;

	if(!this->textures[texturename])
	{
		surface = IMG_Load(("resources/sprites/"+texturename).c_str());

		texture = SDL_CreateTextureFromSurface(this->render, surface);
		this->textures[texturename] = texture;

		SDL_FreeSurface(surface);
	}
	else
		texture = this->textures[texturename];

	SDL_Rect tgt {	(int)round(target_rect.x),
					(int)round(target_rect.y),
					(int)round(target_rect.w),
					(int)round(target_rect.h)};

	SDL_Rect src {	(int)round(src_rect.x),
					(int)round(src_rect.y),
					(int)round(src_rect.w),
					(int)round(src_rect.h)};

	SDL_SetRenderTarget(this->render, target);

	SDL_RenderCopy(this->render, texture, &tgt, &src);
}

void Camera::draw_sprite(std::string texturename, Rect viewport, Rect location,
		int spr_framex, int spr_framey, int totalframesx, int totalframesy)
{
	SDL_Texture *texture;
	SDL_Surface *surface;

	if(!this->textures[texturename])
	{
		surface = IMG_Load(("resources/sprites/"+texturename).c_str());

		texture = SDL_CreateTextureFromSurface(this->render, surface);
		this->textures[texturename] = texture;

		SDL_FreeSurface(surface);
	}
	else
		texture = this->textures[texturename];

	uint32_t format;
	int access;
	int w, h;

	SDL_QueryTexture(texture, &format, &access, &w, &h);

	w /= totalframesx;
	int framex = (spr_framex - 1) * w;
	h /= totalframesy;
	int framey = (spr_framey - 1) * h;


	SDL_Rect frame{framex, framey, w, h};

	double scalex = (((double)this->screenrect.w)/(viewport.w*TILE_SIZE));
	double scaley = (((double)this->screenrect.h)/(viewport.h*TILE_SIZE));


	Rect renderRect;
				// world scale * image height * in game scale
	renderRect.w = scalex * w * (location.w*16/w);
	renderRect.h = scaley * h * (location.h*16/h);

	renderRect.x = -1*viewport.x*TILE_SIZE*scalex  + (.5 * this->screenrect.w) //get viewport translation to screen
					+ location.x*TILE_SIZE*scalex 						//add position
					- (.5 * renderRect.w);								//subtract half the width

	renderRect.y = viewport.y*TILE_SIZE*scaley + (.5 * this->screenrect.h) 
					- location.y*TILE_SIZE*scaley 
					- (.5 * renderRect.h);

	SDL_Rect out{
		(int)round(renderRect.x),
		(int)round(renderRect.y),
		(int)round(renderRect.w),
		(int)round(renderRect.h)
	};

	SDL_SetRenderTarget(this->render, nullptr);

	SDL_RenderCopyEx(this->render, texture, &frame, &out, -1*location.r, nullptr, SDL_FLIP_NONE);

	double life = 1;

	if (life <= .75)
	{
		SDL_SetTextureColorMod(texture, 255, (life*255), (life*255));

		int diff = (double)frame.h - life*frame.h;
		frame.h -= diff;
		frame.y += diff;

		diff = (double)out.h - life*out.h;
		diff = diff - diff%(int)scaley;
		out.h -= diff;
		out.y += diff;

		//SDL_RenderCopyEx(this->render, texture, &frame, &out, -1*rotation, nullptr, SDL_FLIP_NONE);
		SDL_RenderCopy(this->render, texture, &frame, &out);

		SDL_SetTextureColorMod(texture, 255, 255, 255);
	}
}

/*
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

			SDL_Rect out{
				(int)round(renderRect.x),
				(int)round(renderRect.y),
				(int)round(renderRect.w),
				(int)round(renderRect.h)
			};

			SDL_RenderCopyEx(this->render, texture, &frame, &out, -1*spr.rotation, nullptr, SDL_FLIP_NONE);

			if (spr.life <= .75)
			{
				SDL_SetTextureColorMod(texture, 255, (spr.life*255), (spr.life*255));
				spr.life += 0.05; // black sprite borders aren't 
				//std::cout << frame.y << " " << frame.h << std::endl;
				int diff = (double)frame.h - spr.life*frame.h;
				frame.h -= diff;
				frame.y += diff;
				//std::cout << frame.y << " " << frame.h << " " << diff << "\n" << std::endl;

				diff = (double)out.h - spr.life*out.h;
				diff = diff - diff%(int)scaley;
				out.h -= diff;
				out.y += diff;

				//std::cout << diff << " " << scaley << std::endl;

				SDL_RenderCopyEx(this->render, texture, &frame, &out, -1*spr.rotation, nullptr, SDL_FLIP_NONE);

				SDL_SetTextureColorMod(texture, 255, 255, 255);
			}			
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
		else if (it.type == 5)
		{
			DrawUISprite spr = it.data.uisprite;

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

			SDL_Rect out{0, 0, 32, 32};

			SDL_RenderCopy(this->render, texture, nullptr, &out);
		}
	}
}
*/
