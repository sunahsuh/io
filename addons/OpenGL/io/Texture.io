Image do(
	appendProto(OpenGL)
	
	glFormat := method(
		if (componentCount == 1, return(GL_LUMINANCE))
		if (componentCount == 2, return(GL_LUMINANCE_ALPHA))
		if (componentCount == 3, return(GL_RGB))
		if (componentCount == 4, return(GL_RGBA))
		nil
	)
	
	asTexture := method(
		Texture with(self)
	)
)

Texture := Object clone do(
	appendProto(OpenGL)
	
	originalWidth := 0
	originalHeight := 0
	width := 0
	height := 0
	format := nil
	
	with := method(anImage,
		clone setImage(anImage)
	)
	
	id := lazySlot(
		ids := List clone
		glGenTextures(1, ids)
		ids at(0)
	)
	
	bind := method(
		glBindTexture(GL_TEXTURE_2D, id)
		self
	)
	
	setImage := method(anImage,
		setDefaultParameters

		self format = anImage glFormat
		self originalWidth = anImage width
		self originalHeight = anImage height

		anImage = anImage clone resizeToPowerOf2
		self width = anImage width
		self height = anImage height
		
		# Upload the image into the OpenGL system.
		glPixelStorei(GL_UNPACK_ROW_LENGTH, width)
		glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, anImage data)
		
		self
	)

	setDefaultParameters := method(
		bind 
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
	
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
	
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE)

		self
	)
	
	setParameter := method(param, value,
		bind
		glTexParameteri(param, value)
		self
	)
	
	setSWrap := method(value,
		setParameter(GL_TEXTURE_WRAP_S, value)
	)

	setTWrap := method(value,
		setParameter(GL_TEXTURE_WRAP_T, value)
	)
		
	setMinFilter := method(value,
		setParameter(GL_TEXTURE_MIN_FILTER, value)
	)

	setMagFilter := method(value,
		setParameter(GL_TEXTURE_MAG_FILTER, value)
	)
	
	setEnvMode := method(value,
		bind
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, value)
		self
	)
	
	drawScaledArea := method(w, h,
		glPushAttrib(GL_TEXTURE_BIT)
		glEnable(GL_TEXTURE_2D)
		bind

		# the y texture coords are flipped since the image data starts with y=0
		glBegin(GL_QUADS)

		glTexCoord2f(0,  0)
		glVertex2i(0, h)

		glTexCoord2f(0,  1)
		glVertex2i(0, 0)

		glTexCoord2f(1,  1)
		glVertex2i(w, 0)

		glTexCoord2f(1, 0)
		glVertex2i(w, h)

		glEnd
		glPopAttrib

		self
	)
	
	drawArea := method(w, h,
		glPushAttrib(GL_TEXTURE_BIT)
		glEnable(GL_TEXTURE_2D)
		bind

		wr := w / width
		hr := h / height
		
		# the y texture coords are flipped since the image data starts with y=0
		glBegin(GL_QUADS)

		glTexCoord2f(0,  0)
		glVertex2i(0, h)
	
		glTexCoord2f(0,  hr)
		glVertex2i(0, 0)

		glTexCoord2f(wr,  hr)
		glVertex2i(w, 0)

		glTexCoord2f(wr, 0)
		glVertex2i(w, h)

		glEnd
		glPopAttrib

		self
	)
	
	draw := method(
		drawArea(originalWidth, originalHeight)
	)
	
	willFree := method(
		glDeleteTextures(1, list(id))
	)
)
