//import * as $ from 'jquery';
import { Response } from '../core';
import Utilities = require('../utilities');
interface File {
    name: string,
    content: string
}

export interface MaterialInput {
    name: string,
    value: number,
    max: number,
    min: number
}

export interface MaterialType {
    name: string,
    inputs: MaterialInput[],
    rad: string,
    support_files?: File[],
    color_property: string,
    parse: Function,
    process: Function
}

interface Color {
    red: number, 
    green: number, 
    blue:number
}

export interface Material {
    name: string,
    color: Color,
    alpha: number,
    class: string,
    rad: string,
    support_files: File[]
}
