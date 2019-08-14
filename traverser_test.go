// GET abc.url/parent
// {
//     "children": [
//         "abc.url/child1",
//         "abc.url/child2"
//     ],
//     "value": 3
// }
//
// GET abc.url/child1
// {
//     "children": [
//         "abc.url/child3"
//     ],
//     "value": 0.1
// }
//
// GET abc.url/child2
// {
//     "value": 6
// }
//
// GET abc.url/child3
// {
//     "children": [
//         "abc.url/child2"
//     ],
//     "value": -10
// }
//
// /parent, sum: -0.9

