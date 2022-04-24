Q1: 	We used the SnappingSheetController as the controller pattern, with it we can control the
        SnappingSheet using functions such as: setSnappingSheetPosition(...), stopCurrentSnappnig(),
        snapToPosition() etc... And also we can get specific fields of the snappingSheet using methods
        such as: currentlySnapping, currentPosition, isAttached etc...

Q2:	    The snappingCurve parameter controls the animation of the snapping, and the snappingPosition
        controls the position of the snapSheet.

Q3:	    InkWell gives you nice ripple effect, as well provides visual feedback to the user when they
        press down on something, this aids the UI design.
        GestureDetector on the other hand, used to get more custom effects that don't follow material
        design guidelines, and has a variety gestures to deal with the widget.