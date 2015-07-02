/*
 *  Header file for cuRNN tensor class.
 *
 *  Copyright (C) 2015 Rob Clucas robclu1818@gmail.com
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published
 *  by the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT AN_size.y WARRANTY; without even the implied warranty of
 *  MERCHANTABILIT_size.y or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation,
 *	Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef _CURNN_TENSOR_
#define _CURNN_TENSOR_

#include <vector>
#include <iostream>
#include <limits>

namespace curnn  {

// Forward declare
template <typename dType> class tensor4;

/*
 * ==========================================================================================================
 * Class		: tensorBoundChecker 
 *
 * Description	: Defines second level [] operator to allow subscripting for tensor and provides checking of
 *                tensor bounds
 *
 * Params		: dType		: The type of data the subscript must return
 * ==========================================================================================================
 */
template <typename dType>
class tensorBoundChecker {
	public:
		int				dim;	
		tensor4<dType>*	tensor;

	public:
		/*
		 * =================================================================================================
		 * Function		: tensorBoundChecker
		 *
		 * Description	: Constructs the boud checker, initializing the tensor to check the bounds for and
		 *                which of its dimensions must be checked
		 * 
		 * Inputs		: _tensor	: The tensor to check the bounds for
		 *				: _dim		: The dimension of the tensor to check the validity of the subscript
		 *
		 * ==================================================================================================
		 */
		tensorBoundChecker( tensor4<dType>* _tensor, int _dim ) :
			tensor( _tensor ), dim( _dim ) {}

		/*
		 * ==================================================================================================
		 * Function		: operator[]
		 *
		 * Description	: Overloads the [] oeprator allowing it to be used to set value in the tensor
		 *
		 * Inputs		: index		: The index of the element in the dimension to set
		 * ==================================================================================================
		 */
		dType& operator[]( int index ) {
			uint offset;
			switch ( dim ) {
				case 0:
					( index >= 0 && index < tensor->w )	? 
						offset = static_cast<uint>( index )	: 
						offset = std::numeric_limits<uint>::max();
					break;
				case 1:
					( index >= 0 && index < tensor->x )	?
						offset = tensor->w + static_cast<uint>( index )	:
						offset = std::numeric_limits<uint>::max();
					break;
				case 2:
					( index >= 0 && index < tensor->y )	?
						offset = tensor->w + tensor->x + static_cast<uint>( index ) :
						offset = std::numeric_limits<uint>::max();
					break;
				case 3:
					( index >= 0 && index < tensor->z )	?
						offset = tensor->w + tensor->x + tensor->y + static_cast<uint>( index )	:
						offset = std::numeric_limits<uint>::max();
					break;
				default:
					std::cerr << "Dimension " << dim << " not valid for tensor : Returning first element\n";
					return tensor->data[ 0 ];

			}
			if ( offset == std::numeric_limits<uint>::max() ) {
				std::cerr << "Out of Range error for index " << index << 
					         " in tensor dimension " << dim << " : Returning first element\n";
				return tensor->data[ 0 ];
			}
			return tensor->data[ offset ];
		}

		/*
		 * ==================================================================================================
		 * Function		: operator[]
		 *
		 * Description	: Oveloads the [] operator to allow elements of the tensor to be fetched
		 *
		 * Inputs		: index		: The index of the element in the dimension to fetch
		 * ==================================================================================================
		 */
		dType const& operator[]( int index ) const {
			dType output;
			switch ( dim ) {
				case 0:
					( index >= 0 && index < tensor->w )	? 
						output = tensor->data[ index ]	: 
						output = std::numeric_limits<dType>::max();
					break;
				case 1:
					( index >= 0 && index < tensor->x )	?
						output = tensor->data[ tensor->w + index ]	:
						output = std::numeric_limits<dType>::max();
					break;
				case 2:
					( index >= 0 && index < tensor->y )	?
						output = tensor->data[ tensor->w + tensor->x + index ]	:
						output = std::numeric_limits<dType>::max();
					break;
				case 3:
					( index >= 0 && index < tensor->z )				?
						output = tensor->data[ tensor->w + tensor->x + tensor->y + index ]	:
						output = std::numeric_limits<dType>::max();
					break;
				default:
					std::cerr << "Dimension " << dim << " not valid for tensor : Returning max value\n";
					return std::numeric_limits<dType>::max();
			}
			if ( output == std::numeric_limits<dType>::max() ) {
				std::cerr << "Out of Range error for index " << index << 
					         " in tensor dimension " << dim << " : Returning max value\n";
			}
			return output;
		}
};

/*
 * ==========================================================================================================
 * Class		: tensor4
 *
 * Description	: Provides a 4D tensor to store 4 dimensionaly data, or to join data to 4 dimensions to that
 *				  less passes need to be made to the GPU
 *
 * Params		: dType		: The data type for the matrix
 * ==========================================================================================================
 */
template <typename dType>
class tensor4 {
	public:
		uint				w;
		uint				x;
		uint				y; 
		uint				z;
		std::vector<dType>	data;
	public:
		/*
		 * ==================================================================================================
		 * Function			: tensor4 
		 *
		 * Description		: Default constructor which sets the dimensions of the tensor to be 0
		 * ==================================================================================================
		 */
		explicit tensor4() :
			w( 0 ), x ( 0 ), y ( 0 ), z ( 0 ) {}

		/*
		 * ==================================================================================================
		 * Function			: tensor4 (constructor)
		 *
		 * Description		: Sets the number of elements in each dimension of the tensor and allocates and 
		 *					  sets the tensor data to be zero
		 *
		 * Inputs			: _w	: Number of elements in the 1st dimension
		 *					: _x	: Number of elements in the 2nd dimension
		 *					: _y	: Number of elements in the 3rd dimension
		 *					: _z	: Number of elements in the 4th dimension
		 * ==================================================================================================
		 */
		explicit tensor4( uint _w, uint _x, uint _y, uint _z ) :
			w( _w ), x( _x ), y( _y ), z( _z ), data( _w * _x * y * _z, 0 ) {}

		/* ==================================================================================================
		 * Function		: size
		 *
		 * Description	: Retuns the size of the tensor (total number of elements)
		 * ==================================================================================================
		 */
		__inline__ __device__ __host__ size_t size() {
			return data.size();
		}

		/*
		 * ==================================================================================================
		 * Function		: reshape 
		 *
		 * Description	: Reshapes the tensor along each dimension, -1 keeps the dimensionality 
		 *
		 * Inputs		: w_new		: New number of elements for 1st dimensino
		 *				: x_new		: New number of elements for 2nd dimension
		 *				: y_new		: New number of elements for 3rd dimension
		 *				: z_new		: New number of elements for 4th dimension
		 * ==================================================================================================
		 */
		__inline__ __device__ __host__ void reshape( int w_new, int x_new, int y_new, int z_new ) {
			w = ( w_new != -1 ) ? static_cast<uint>(w_new) : w;		
			x = ( x_new != -1 ) ? static_cast<uint>(x_new) : x;		
			y = ( y_new != -1 ) ? static_cast<uint>(y_new) : y;		
			z = ( z_new != -1 ) ? static_cast<uint>(z_new) : z;		
			data.resize( w * x * y * z, 0 );
		}

		/*
		 * ==================================================================================================
		 * Function		: operator() 
		 *
		 * Description	: Overload () operator to allow use in consructor
		 * Params		: dType		: The data type for the matrix
		 *				: _w		: Num elements in 1st dimension
		 *				: _x		: Num elements in 2nd dimension
		 *				: _y		: Num elements in 3rd dimension
		 *				: _z		: Num elements in 4th dimension*
		 * ==================================================================================================
		 */
		__inline__ __device__ __host__ void operator() ( uint w_new, uint x_new, uint y_new, uint z_new ) {
			w = w_new; x = x_new; y = y_new; z = z_new;
			data( w * x * y * z,  0 );
		}

		/*
		 * ==================================================================================================
		 * Function		: operator[]
		 *
		 * Description	: Overloads the subscript operator to allow access by [][] because the vector class
		 *                also has an [] operator.
		 *
		 * Inputs		: index		: The index of dimension that the data must be fetched from
		 *
		 * Outputs		: A reference to the element that represents the first element in the dimension that
		 *                is specified in the input 
		 * ==================================================================================================
		 */ 
		tensorBoundChecker<dType> operator[]( int dim ) {
			return tensorBoundChecker<dType>( this, dim );
		}
};

}
#endif
