//
//  GameObject.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#include "GameObject.h"
#include "GameObjectContainer.h"

/** @brief Remove the game object from the layer, game object collection, etc.
 * c.f. This is called when the game object goes out of the screen area that can be shown.
 */
void GameObject::removeSelf() {
    assert(_container);

    _container->remove( shared_from_this() );
}
