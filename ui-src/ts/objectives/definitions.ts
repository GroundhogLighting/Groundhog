import { Response, Range } from '../core';
import Utilities = require('../utilities');

interface Requirement {
    name: string,
    value: any
}

export interface ObjectiveType {
    metric: string,
    name: string,
    requirements: Requirement[],
    dynamic: boolean,
    good_light_legend: string,
    human_language: string
} 
