/*

void print(std::deque<value> deq)
{
    std::deque<value>::iterator it;
    std::cout << "printing deque\n" ;
    for(it = deq.begin(); it != deq.end(); ++it)
    {
        printf("element:%d\n", *it);
    }
    std::cout << "\ndone.\n" ;
}

int rtree_test() 
{
    try {
        rtree r(16,4);
        
        r.print();
        
        r.insert( box(point(1.0, 1.0), point(1.9, 1.9)), 1 );
        r.insert( box(point(1.1, 1.1), point(1.8, 1.8)), 2 );
        r.insert( box(point(1.2, 1.2), point(1.7, 1.7)), 3 );
        r.insert( box(point(1.3, 1.3), point(1.6, 1.6)), 4 );
        r.insert( box(point(1.4, 1.4), point(1.5, 1.5)), 5 );
        
        r.print();
        
        std::deque<value> v;
        v = r.find(box(point(0.0, 1.25), point(100, 1.65)));
        
        print(v); 
    }catch(std::exception e){
        std::cerr<<e.what();
    }
}
*/