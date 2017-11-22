import Utilities = require('../Utilities');
import { Response } from '../../common/core';

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
