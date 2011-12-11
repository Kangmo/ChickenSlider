//
//  CppInfra.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_CppInfra_h
#define rocknroll_CppInfra_h

#include <iostream>
#include <string>
#include <set>
#include <boost/tr1/memory.hpp>
#include <boost/geometry.hpp>
#include <boost/geometry/extensions/index/rtree/rtree.hpp>
#include <boost/tr1/memory.hpp>
#include <boost/foreach.hpp>
#include <boost/tokenizer.hpp>

#define REF(ClassName) boost::shared_ptr<ClassName>
typedef boost::geometry::model::d2::point_xy<float> point_t;
typedef boost::geometry::model::box<point_t> box_t;

typedef std::vector<std::string> StringVector;

#endif
