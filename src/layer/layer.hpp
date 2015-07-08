/*
 *  Header file for cuRNN layer class.
 *
 *  Copyright (C) 2015 Rob Clucas robclu1818@gmail.com
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published
 *  by the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation,
 *  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef _CURNN_LAYER_
#define _CURNN_LAYER_

#include "../tensor/tensor.cuh"
#include "../math/math.hpp"

namespace curnn {

/*
 * ==========================================================================================================
 * Class        : layer 
 *
 * Description  : Layer class for the cuRNN that defines a generic class for a layer
 *
 * Params       : dType         : The type of data for the layer
 *              : _nodes        : The number of nodes in the layer
 *              : _inputs       : The number of inputs to the layer
 *              : _depth        : The number of timesteps back or forward that have inputs to this layer
 *              : typePolicy    : The type of layer
 * ==========================================================================================================
 */
template <typename                            dType,
          uint                                _nodes,
          uint                                _inputs,
          uint                                _depth,
          template <typename, uint...>  class typePolicy >     
class layer : public typePolicy<dType, _nodes, _inputs, _depth> {  
    public:
        uint                numNodes;
        uint                numInputs;
        uint                depth;
        std::vector<dType>  outputs;
    public:
        /*
         * ==================================================================================================
         * Function     : layer 
         *
         * Description  : Defines the size of the layer parameters. The wights are stores as pages where each
         *                page is the weights between the inputs or a previous iteration of a hidden layer. 
         *                Each page has the following format :
         *                
         *                | Woo Wo1 ... WoN | N = nodes
         *                | W1o W11 ... W1N |
         *                |  .   .  .    .  |
         *                |  .   .    .  .  | 
         *                | WM0 WM1     WMN | M = max( inputs, nodes )
         *                | boP b1P ... bNP | b = bias, P = page = inputs, hidden_-1, hidden_-2 etc
         *                | aoP a1P ... aNP | a = activation, from Wx + b from its page
         *
         * ==================================================================================================
         */
        explicit layer() :
            numNodes( _nodes ), numInputs( _inputs ), depth( _depth ), outputs( _nodes, 0 ) {}

        /*
         * ==================================================================================================
         * Function     : initializeWeights 
         * 
         * Description  : Initialzes the weights between a certain range (by default the weights are
         *                initialized to 0 during construction.
         *
         * Inputs       : min   : The minimum value for the weights
         *              : max   : The maximum value for the weights
         * ==================================================================================================
         */
        inline void initializeWeights( dType min, dType max ) {
            for ( uint d = 0; d < depth; d++ ) {
                for( uint i = 0; i < numInputs; i++ ) {
                    for ( uint n = 0; n < numNodes; n++ ) {
                       this->wba( n, i, d, 0 ) = curnn::math::rand( min, max );
                    }
                }
            }
        }
        
        /*
         * ==================================================================================================
         * Function     : getWeights
         * 
         * Description  : Returns a constant pointer to the weights (read-only)
         * 
         * Outputs      : A constant pointer to the weights, biases, and activations of the layer
         * ==================================================================================================
         */
        inline const tensor4<dType>& getWBA() const { 
            // wba tensor in the typePolicy instance
            return this->wba;
        }
        
        /*
         * ==================================================================================================
         * Function     : outputs 
         *
         * Description  : Retuns a pointer to the outputs of the layer
         *
         * Outputs      : A constant pointer to the outputs of the layer
         * ==================================================================================================
         */
        inline const dType* getOutputs() const {
            return &outputs[ 0 ]; 
        }
        
        /*
         * ==================================================================================================
         * Function     : getErrors
         *
         * Description  : Retuns a pointer to the errors of the layer
         *
         * Outputs      : A constant pointer to the errors of the layer
         * ==================================================================================================
         */
        inline const dType* getErrors() const {
            // Errors vector in typepolicy base
            return &(this->errors[ 0 ]); 
        }
};

}   // Namespace curnn

#endif
