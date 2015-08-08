//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.kha;


import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.subsystem.RendererSystem;
import flambe.util.Assert;
import flambe.util.Value;

class KhaRenderer
    implements InternalRenderer<Dynamic>
{
    public var type (get, null) :RendererType;
    public var maxTextureSize (get, null) :Int;
    public var hasGPU (get, null) :Value<Bool>;

    public var graphics :InternalGraphics;

    public var g (default, null) :RenderingContext;
    public var batcher (default, null) :Batcher;

    public function new (stage :KhaStage, g :kha.graphics2.Graphics)
    {
        _hasGPU = new Value<Bool>(true);
        this.g = g;

        // Handle GL context loss
        g.canvas.addEventListener("webglcontextlost", function (event) {
            event.preventDefault();
            Log.warn("WebGL context lost");
            _hasGPU._ = false;
        }, false);
        g.canvas.addEventListener("webglcontextrestore", function (event) {
            Log.warn("WebGL context restored");
            init();
            _hasGPU._ = true;
        }, false);
		
        stage.resize.connect(onResize);
        init();
    }

    inline private function get_type () :RendererType
    {
        return WebGL;
    }

    private function get_maxTextureSize () :Int
    {
        return g.getParameter(GL.MAX_TEXTURE_SIZE);
    }

    inline private function get_hasGPU () :Value<Bool>
    {
        return _hasGPU;
    }

    public function createTextureFromImage (image :Dynamic) :KhaTexture
    {
        if (g.isContextLost()) {
            return null;
        }
        var root = new KhaTextureRoot(this, image.width, image.height);
        root.uploadImageData(image);
        return root.createTexture(image.width, image.height);
    }

    public function createTexture (width :Int, height :Int) :KhaTexture
    {
        /*if (g.isContextLost()) {
            return null;
        }*/
		
        var root = new KhaTextureRoot(this, width, height);
        root.clear();
        return root.createTexture(width, height);
    }

    public function getCompressedTextureFormats () :Array<AssetFormat>
    {
        // TODO(bruno): Detect supported texture extensions
        return [];
    }

    public function createCompressedTexture (format :AssetFormat, data :Bytes) :KhaTexture
    {
        if (g.isContextLost()) {
            return null;
        }
        Assert.fail(); // Unsupported
        return null;
    }

    public function willRender ()
    {
        graphics.willRender();
    }

    public function didRender ()
    {
        graphics.didRender();
    }

    private function onResize ()
    {
        var width = g.canvas.width, height = g.canvas.height;
        batcher.resizeBackbuffer(width, height);
        graphics.onResize(width, height);
    }

    private function init ()
    {
        batcher = new Batcher(g);
        graphics = new KhaGraphics(batcher, null);
        onResize();
    }

    private var _hasGPU :Value<Bool>;
}
