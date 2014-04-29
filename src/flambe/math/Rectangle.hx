//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.math;

/**
 * A 2D rectangle.
 */
class Rectangle
{
    public var x :Float;
    public var y :Float;
    public var width :Float;
    public var height :Float;

    /** The X-coordinate of the left side of the rectangle. */
    public var left (get, null) :Float;

    /** The X-coordinate of the right side of the rectangle. */
    public var right (get, null) :Float;

    /** The Y-coordinate of the top side of the rectangle. */
    public var top (get, null) :Float;

    /** The Y-coordinate of the bottom side of the rectangle. */
    public var bottom (get, null) :Float;

    /** The X-coordinate of the center of the rectangle. */
    public var centerX (get, null) :Float;

    /** The Y-coordinate of the center of the rectangle. */
    public var centerY (get, null) :Float;

    public function new (x :Float = 0, y :Float = 0, width :Float = 0, height :Float = 0)
    {
        set(x, y, width, height);
    }

    /**
     * Calculates the intersection between two Rectangles. If the rectangles do not intersect,
     * this method returns an empty Rectangle object with its properties set to 0.
     */
    public static function intersect (rect1 :Rectangle, rect2 :Rectangle, ?result: Rectangle) :Rectangle
    {

        if (result == null) {
            result = new Rectangle();
        }

        var left:Float = rect1.x > rect2.x ? rect1.x : rect2.x;
        var right:Float = rect1.right < rect2.right ? rect1.right : rect2.right;
        var top:Float = rect1.y > rect2.y ? rect1.y : rect2.y;
        var bottom:Float = rect1.bottom < rect2.bottom ? rect1.bottom : rect2.bottom;
        
        if (left > right || top > bottom)
            result.set(0, 0, 0, 0);
        else
            result.set(left, top, right-left, bottom-top);
            
        return result;
    }

    public function set (x :Float, y :Float, width :Float, height :Float)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    /**
     * Returns true if this rectangle contains the given point.
     */
    public function contains (x :Float, y :Float) :Bool
    {
        // A little more complicated than usual due to proper handling of negative widths/heights

        x -= this.x;
        if (width >= 0) {
            if (x < 0 || x > width) {
                return false;
            }
        } else if (x > 0 || x < width) {
            return false;
        }

        y -= this.y;
        if (height >= 0) {
            if (y < 0 || y > height) {
                return false;
            }
        } else if (y > 0 || y < height) {
            return false;
        }

        return true;
    }

    /**
     * Creates a copy of this rectangle.
     */
    public function clone (?result :Rectangle) :Rectangle
    {
        if (result == null) {
            result = new Rectangle();
        }
        result.set(x, y, width, height);
        return result;
    }

    public function equals (other :Rectangle) :Bool
    {
        return x == other.x && y == other.y && width == other.width && height == other.height;
    }

    #if debug @:keep #end public function toString () :String
    {
        return "(" + x + "," + y + " " + width + "x" + height + ")";
    }

    inline private function get_left () :Float
    {
        return x;
    }

    inline private function get_top () :Float
    {
        return y;
    }

    private function get_right () :Float
    {
        return x + width;
    }

    private function get_bottom () :Float
    {
        return y + height;
    }

    private function get_centerX () :Float
    {
        return x + width/2;
    }

    private function get_centerY () :Float
    {
        return y + height/2;
    }
}
