//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.kha;

import flambe.platform.TextureRoot;
import js.html.CanvasElement;
import js.html.Uint8Array;
import js.html.webgl.*;
import kha.Image;

import haxe.io.Bytes;

import flambe.math.FMath;
import flambe.platform.MathUtil;

class KhaTextureRoot extends BasicAsset<KhaTextureRoot>
    implements TextureRoot
{
    // The power of two dimensions of the texture
    public var width (default, null) :Int;
    public var height (default, null) :Int;

    public var nativeTexture (default, null) :Image;

    public function new (renderer :KhaRenderer, width :Int, height :Int)
    {
        super();
        _renderer = renderer;
        // 1 px textures cause weird DrawPattern sampling on some drivers
        this.width = FMath.max(2, MathUtil.nextPowerOfTwo(width));
        this.height = FMath.max(2, MathUtil.nextPowerOfTwo(height));
;
		
		nativeTexture = Image.createRenderTarget(width, height)
		
    
    }

    public function createTexture (width :Int, height :Int) :KhaTexture
    {
        return new KhaTexture(this, width, height);
    }

   

    public function readPixels (x :Int, y :Int, width :Int, height flambve:Int) :Bytes
    {
		/*
        assertNotDisposed();

        getGraphics(); // Ensure we have a framebuffer
        _renderer.batcher.bindFramebuffer(this);

        var pixels = new Uint8Array(4*width*height);
        var gl = _renderer.g;
        gl.readPixels(x, y, width, height, GL.RGBA, GL.UNSIGNED_BYTE, pixels);

        // Undo alpha premultiplication. This is lossy!
        var ii = 0, ll = pixels.length;
        while (ii < ll) {
            var invAlpha = 255 / pixels[ii+3];
            pixels[ii] = cast pixels[ii] * invAlpha;
            ++ii;
            pixels[ii] = cast pixels[ii] * invAlpha;
            ++ii;
            pixels[ii] = cast pixels[ii] * invAlpha;
            ii += 2; // Advance to next pixel
        }

        return Bytes.ofData(cast pixels);*/
		
		//TODO(Sidar)
		return null;
		
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
        /*assertNotDisposed();

        _renderer.batcher.bindTexture(nativeTexture);

        // Can't update a texture used by a bound framebuffer apparently
        _renderer.batcher.bindFramebuffer(null);

        var gl = _renderer.g;
        // TODO(bruno): Avoid the redundant Uint8Array copy
        gl.texSubImage2D(GL.TEXTURE_2D, 0, x, y, sourceW, sourceH,
            GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array(pixels.getData()));*/
			
			//TODO(Sidar)
    }

    public function getGraphics () :KhaGraphics
    {
        assertNotDisposed();

        if (_graphics == null) {
            _graphics = new KhaGraphics(nativeTexture.g2, this);
            _graphics.onResize(width, height);
        }
        return _graphics;
    }

    override private function copyFrom (that :KhaTextureRoot)
    {
        this.nativeTexture = that.nativeTexture;
        this.framebuffer = that.framebuffer;
        this.width = that.width;
        this.height = that.height;
        this._graphics = that._graphics;
    }

    override private function onDisposed ()
    {
        var batcher = _renderer.batcher;
        batcher.deleteTexture(this);
        if (framebuffer != null) {
            batcher.deleteFramebuffer(this);
        }

        nativeTexture = null;
        framebuffer = null;
        _graphics = null;
    }

    /**
     * Extends the right and bottom edge pixels of a bitmap. This is to prevent artifacts caused by
     * sampling the outer transparency when the edge pixels are sampled.
     */
    private static function drawBorder (canvas :CanvasElement, width :Int, height :Int)
    {
        var ctx = canvas.getContext2d();

        // Right edge
        ctx.drawImage(canvas, width-1, 0, 1, height, width, 0, 1, height);

        // Bottom edge
        ctx.drawImage(canvas, 0, height-1, width, 1, 0, height, width, 1);

        // Is a one pixel border enough?
    }

    private var _renderer :KhaRenderer;
    private var _graphics :KhaGraphics = null;
}
