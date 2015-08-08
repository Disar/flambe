//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.kha;

import kha.Color;
import kha.graphics2.Graphics;
import kha.graphics2.GraphicsExtension;
import kha.graphics4.BlendingOperation;
import kha.math.Matrix3;

import flambe.display.BlendMode;
import flambe.display.Texture;
import flambe.math.FMath;
import flambe.math.Matrix;
import flambe.math.Rectangle;
import flambe.util.Assert;

class KhaGraphics implements InternalGraphics
{
	
	private var g:Graphics;
	
    public function new (KhaRenderContext:Graphics,renderTarget :KhaTextureRoot)
    {
		g = KhaRenderContext;
        _renderTarget = renderTarget;
    }

    public function save ()
    {
        var current = _stateList;
        var state = _stateList.next;

        if (state == null) {
            // Grow the list
            state = new DrawingState();
            state.prev = current;
            current.next = state;
        }

        current.matrix.clone(state.matrix);
        state.alpha = current.alpha;
        state.blendMode = current.blendMode;
        state.scissor = (current.scissor != null) ? current.scissor.clone(state.scissor) : null;
        _stateList = state;
    }

    public function translate (x :Float, y :Float)
    {
        var matrix = getTopState().matrix;
        matrix.m02 += matrix.m00*x + matrix.m01*y;
        matrix.m12 += matrix.m10*x + matrix.m11*y;
    }

    public function scale (x :Float, y :Float)
    {
        var matrix = getTopState().matrix;
        matrix.m00 *= x;
        matrix.m10 *= x;
        matrix.m01 *= y;
        matrix.m11 *= y;
    }

    public inline function rotate (rotation :Float)
    {
		
        rotation = FMath.toRadians(rotation);
        var sin = Math.sin(rotation);
        var cos = Math.cos(rotation);
        var m00 = matrix.m00;
        var m10 = matrix.m10;
        var m01 = matrix.m01;
        var m11 = matrix.m11;

        matrix.m00 = m00*cos + m01*sin;
        matrix.m10 = m10*cos + m11*sin;
        matrix.m01 = m01*cos - m00*sin;
        matrix.m11 = m11*cos - m10*sin;
    }

    public function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
        var state = getTopState();
        _scratchMatrix.set(m00, m10, m01, m11, m02, m12);
        Matrix.multiply(state.matrix, _scratchMatrix, state.matrix);
    }

    public function restore ()
    {
        Assert.that(_stateList.prev != null, "Can't restore without a previous save");
        _stateList = _stateList.prev;
    }

    public function drawTexture (texture :KhaTexture, x :Float, y :Float)
    {
         g.drawImage(texture, destX, destY);
    }

    public function drawSubTexture (texture :KhaTexture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
	   g.rotate(_stateList.rotation, 0, 0);
	   g.set_color(_stateList.color);
       g.set_opacity(_stateList.alpha);
	   g.drawSubImage(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
	   
    }

    public function drawPattern (texture :KhaTexture, x :Float, y :Float, width :Float, height :Float)
    {
        var state = getTopState();
        var texture :KhaTexture = cast texture;
        var root = texture.root;
        
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
		
        var state = getTopState();
		
		g.set_color(Color.fromValue(color);
		g.set_opacity(state.alpha);
		g.fillRect(x, y, width, height);
		
    }

    public function multiplyAlpha (factor :Float)
    {
        getTopState().alpha *= factor;
    }

    public function setAlpha (alpha :Float)
    {
        getTopState().alpha = alpha;
    }

    public function setBlendMode (blendMode :BlendMode)
    {
        getTopState().blendMode = blendMode;
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
        state.applyScissor(x, y, width, height);
    }

    public function willRender ()
    {
		g.begin();
		#if flambe_transparent
        g.clear(Color.fromFloats(0, 0, 0, 0);
		#end
       
    }

    public function didRender ()
    {
		flush();
        g.end();
    }

	function flush() : void {
		
		if (_lastBlendMode != _currentBlendMode) {
            switch (_lastBlendMode) {
                case Normal: g.setBlendingMode(BlendingOperation.BlendOne, BlendingOperation.InverseSourceAlpha);
                case Add: g.blendFunc(BlendingOperation.BlendOne, BlendingOperation.BlendOne);
                //case Multiply: g.blendFunc(GL.DST_COLOR, BlendingOperation.InverseSourceAlpha);
                //case Screen: g.blendFunc(BlendingOperation.BlendOne, GL.ONE_MINUS_SRC_COLOR);
                case Mask: g.blendFunc(BlendingOperation.BlendZero,BlendingOperation.SourceAlpha);
                case Copy: g.blendFunc(BlendingOperation.BlendOne, BlendingOperation.BlendZero); // TODO(bruno): Disable blending entirely?
            }
            _currentBlendMode = _lastBlendMode;
        }
	}
	
    public function onResize (width :Int, height :Int)
    {
        _stateList = new DrawingState();

        // Framebuffers need to be vertically flipped
        var flip = (_renderTarget != null) ? -1 : 1;
        _stateList.matrix.set(2/width, 0, 0, flip * -2/height, -1, flip);

        // May be used to transform back into screen coordinates
        _inverseProjection = new Matrix();
        _inverseProjection.set(2/width, 0, 0, 2/height, -1, -1);
        _inverseProjection.invert();
    }

    inline private function getTopState () :DrawingState
    {
        return _stateList;
    }

    private function transformQuad (x :Float, y :Float, width :Float, height :Float) :Float32Array
    {
        var x2 = x + width;
        var y2 = y + height;
        var pos = _scratchQuadArray;

        pos[0] = x;
        pos[1] = y;

        pos[2] = x2;
        pos[3] = y;

        pos[4] = x2;
        pos[5] = y2;

        pos[6] = x;
        pos[7] = y2;

        getTopState().matrix.transformArray(cast pos, 8, cast pos);
        return pos;
    }

    private static var _scratchMatrix = new Matrix();
    private static var _scratchQuadArray :Float32Array = null;

    private var _batcher :Batcher;
    private var _renderTarget :KhaTextureRoot;

    private var _inverseProjection :Matrix = null;
    private var _stateList :DrawingState = null;
	
	    // Used to keep track of context changes requiring a flush
    private var _lastBlendMode :BlendMode = null;
    private var _lastRenderTarget :KhaTextureRoot = null;
    private var _lastShader :ShaderGL = null;
    private var _lastTexture :Texture = null;
    private var _lastScissor :Rectangle = null;
	
}

private class DrawingState
{
    public var rotation:Float;
    public var alpha :Float;
    public var blendMode :BlendMode;
    public var scissor :Rectangle = null;
	public var color:Color = Color.White;
	
	

    public var prev :DrawingState = null;
    public var next :DrawingState = null;

    public function new ()
    {
        matrix = new Matrix();
        alpha = 1;
        blendMode = Normal;
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
        if (scissor != null) {
            // Intersection with the previous scissor rectangle
            var x1 = FMath.max(scissor.x, x);
            var y1 = FMath.max(scissor.y, y);
            var x2 = FMath.min(scissor.x + scissor.width, x + width);
            var y2 = FMath.min(scissor.y + scissor.height, y + height);
            x = x1;
            y = y1;
            width = x2 - x1;
            height = y2 - y1;
        } else {
            scissor = new Rectangle();
        }
        scissor.set(Math.round(x), Math.round(y), Math.round(width), Math.round(height));
    }
}
